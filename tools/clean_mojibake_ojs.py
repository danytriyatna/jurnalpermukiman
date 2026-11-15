#!/usr/bin/env python3
"""
clean_mojibake_ojs.py - Automated Mojibake & Encoding Normalization Tool for OJS Databases
Author: Maya Kirana Valarie & Dany Triyatna
Date: 2026-11-15
Description:
  Scans and repairs corrupted UTF-8 byte sequences (Mojibake) in OJS 3.3+ databases
  caused by legacy latin1/swedish_ci imports and PHP 8.x character conversions.
  Ensures safe handling of serialized settings, creates deterministic transactional
  updates, and exports a standalone clean_ojs_data.sql for reproducible deployments.
"""

import sys
import os
import subprocess
import argparse
from datetime import datetime

# Exact order: Longest patterns first to prevent premature collision
MOJIBAKE_MAP = [
    # Triple / double Mojibake variations (spam or multi-import)
    ('ÃƒÂ©', 'é'),
    ('ÃƒÂ\xa0', 'à'),
    ('ÃƒÂ\x82', ''),
    ('ÃƒÂ ', 'à'),
    ('ÃƒÂ', 'à'),

    # 3-character punctuation patterns (MUST BE BEFORE 'â€')
    ('â€œ', '"'),
    ('â€\x9d', '"'),
    ('â€™', "'"),
    ('â€˜', "'"),
    ('â€”', '—'),
    ('â€“', '–'),
    ('â€¦', '...'),
    ('â€¢', '•'),
    # Fallback 2-character
    ('â€', '"'),

    # Accented letters
    ('Ã¤', 'ä'),
    ('Ã¶', 'ö'),
    ('Ã¼', 'ü'),
    ('Ã„', 'Ä'),
    ('Ã–', 'Ö'),
    ('Ãœ', 'Ü'),
    ('Ã©', 'é'),
    ('Ã¨', 'è'),
    ('Ã¡', 'á'),
    ('Ã­', 'í'),
    ('Ã³', 'ó'),
    ('Ãº', 'ú'),
    ('Ã±', 'ñ'),
    ('Ã§', 'ç'),

    # Symbols with Â
    ('Â°', '°'),
    ('Â±', '±'),
    ('Â²', '²'),
    ('Â³', '³'),
    ('Âµ', 'µ'),
    ('Â¼', '¼'),
    ('Â½', '½'),
    ('Â¾', '¾'),

    # Stray non-breaking spaces
    ('Â ', ' '),
    ('\xc2\xa0', ' '),
    ('\xa0', ' '),
    ('&nbsp;', ' '),
]

def clean_text(text):
    if not text:
        return text
    res = text
    for bad, good in MOJIBAKE_MAP:
        res = res.replace(bad, good)
    # Clean any remaining isolated Â
    res = res.replace('Â', '')
    return res

def sql_escape(s):
    if s is None:
        return "NULL"
    return "'" + s.replace("\\", "\\\\").replace("'", "''").replace("\0", "\\0").replace("\n", "\\n").replace("\r", "\\r") + "'"

class OJSDBFixer:
    def __init__(self, db_name='ojs33_gc2', user='root', password='', host='localhost', port=3306, mysql_bin=None):
        self.db_name = db_name
        self.user = user
        self.password = password
        self.host = host
        self.port = port
        self.mysql_bin = mysql_bin or r'C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe'
        self.temp_dir = os.path.dirname(os.path.abspath(__file__))
        self.all_updates = []

    def run_query(self, sql):
        sql_file = os.path.join(self.temp_dir, '_tmp_run.sql')
        with open(sql_file, 'w', encoding='utf-8') as f:
            f.write(f"USE `{self.db_name}`;\nSET NAMES utf8mb4;\n{sql}\n")
        
        cmd = [
            self.mysql_bin,
            f'-h{self.host}',
            f'-P{self.port}',
            f'-u{self.user}',
            '--default-character-set=utf8mb4',
            '-N', '-B',
            '-e', f'source {sql_file.replace(os.sep, "/")}'
        ]
        if self.password:
            cmd.insert(4, f'-p{self.password}')
            
        res = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
        if os.path.exists(sql_file):
            try:
                os.remove(sql_file)
            except OSError:
                pass
                
        if res.returncode != 0:
            raise Exception(f"MySQL Error: {res.stderr}")
        return res.stdout

    def clean_table(self, table_name, pk_cols, target_cols, extra_where=""):
        print(f"[*] Auditing table `{table_name}`...")
        cols_to_select = pk_cols + target_cols
        # Use CONCAT_WS with custom delimiters to avoid newline splitting errors
        concat_fields = ", ".join([f"COALESCE(`{c}`, '')" for c in cols_to_select])
        query_expr = f"CONCAT(CONCAT_WS('|||COL|||', {concat_fields}), '|||ROW|||')"
        where_clause = f" WHERE {extra_where}" if extra_where else ""
        query = f"SELECT {query_expr} FROM `{table_name}`{where_clause};"
        
        try:
            raw_output = self.run_query(query)
        except Exception as e:
            print(f"    [!] Error reading table `{table_name}`: {e}")
            return 0

        raw_rows = [r for r in raw_output.split('|||ROW|||\n') if r.strip()]
        if not raw_rows:
            print(f"    -> Table `{table_name}` is empty or no matching rows.")
            return 0

        updates = []
        num_pk = len(pk_cols)
        
        for raw_r in raw_rows:
            parts = raw_r.split('|||COL|||')
            if len(parts) < len(cols_to_select):
                continue
            pk_vals = parts[:num_pk]
            col_vals = parts[num_pk:]
            
            changes = {}
            for col_idx, orig_val in enumerate(col_vals):
                col_name = target_cols[col_idx]
                
                # Safety check: Skip PHP serialized arrays
                if orig_val.startswith('a:') or orig_val.startswith('O:') or orig_val.startswith('s:'):
                    continue
                    
                cleaned = clean_text(orig_val)
                if cleaned != orig_val:
                    changes[col_name] = cleaned
            
            if changes:
                set_clauses = [f"`{col}` = {sql_escape(val)}" for col, val in changes.items()]
                pk_clauses = [f"`{pk_col}` = {sql_escape(pk_val)}" for pk_col, pk_val in zip(pk_cols, pk_vals)]
                stmt = f"UPDATE `{table_name}` SET {', '.join(set_clauses)} WHERE {' AND '.join(pk_clauses)};"
                updates.append(stmt)
                self.all_updates.append(stmt)

        print(f"    -> Identified {len(updates)} rows requiring normalization in `{table_name}`.")
        
        if updates:
            batch_size = 200
            for i in range(0, len(updates), batch_size):
                chunk = updates[i:i+batch_size]
                batch_sql = "START TRANSACTION;\n" + "\n".join(chunk) + "\nCOMMIT;"
                self.run_query(batch_sql)
            print(f"    [+] Successfully updated {len(updates)} rows in `{table_name}`.")
            
        return len(updates)

    def execute_all(self):
        print(f"=== Starting OJS Mojibake Normalization on Database `{self.db_name}` ===")
        total_repaired = 0

        # Table configurations
        configs = [
            # 1. Citations
            ('citations', ['citation_id'], ['raw_citation'], ""),
            # 2. Publication Settings
            ('publication_settings', ['publication_id', 'locale', 'setting_name'], ['setting_value'], ""),
            # 3. Author Settings
            ('author_settings', ['author_id', 'locale', 'setting_name'], ['setting_value'], ""),
            # 4. Journal Settings
            ('journal_settings', ['journal_id', 'locale', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 5. User Settings
            ('user_settings', ['user_id', 'locale', 'setting_name', 'assoc_type', 'assoc_id'], ['setting_value'], "setting_type != 'object'"),
            # 6. Notes
            ('notes', ['note_id'], ['contents'], ""),
            # 7. Metadata Description Settings
            ('metadata_description_settings', ['metadata_description_id', 'locale', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 8. Citation Settings
            ('citation_settings', ['citation_id', 'locale', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 9. Controlled Vocab Entry Settings
            ('controlled_vocab_entry_settings', ['controlled_vocab_entry_id', 'locale', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 10. Navigation Menu Item Settings
            ('navigation_menu_item_settings', ['navigation_menu_item_id', 'locale', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 11. Event Log Settings
            ('event_log_settings', ['log_id', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 12. Review Form Responses
            ('review_form_responses', ['review_form_element_id', 'review_id'], ['response_value'], ""),
            # 13. RT Searches
            ('rt_searches', ['search_id'], ['title', 'description'], ""),
            # 14. Genre Settings
            ('genre_settings', ['genre_id', 'locale', 'setting_name'], ['setting_value'], "setting_type != 'object'"),
            # 15. Email Templates Default Data
            ('email_templates_default_data', ['email_key', 'locale'], ['subject', 'body'], ""),
            # 16. Email Log
            ('email_log', ['log_id'], ['subject', 'body'], ""),
            # 17. Submission Search Keyword List
            ('submission_search_keyword_list', ['keyword_id'], ['keyword_text'], ""),
        ]

        for tbl, pks, cols, extra in configs:
            repaired = self.clean_table(tbl, pks, cols, extra)
            total_repaired += repaired

        print(f"\n[+] Total rows repaired in this run: {total_repaired}")

        # Export SQL artifact for future migrations
        sql_export_path = os.path.join(self.temp_dir, 'clean_ojs_data.sql')
        with open(sql_export_path, 'w', encoding='utf-8') as f:
            f.write(f"-- OJS Mojibake Cleanup Script for Production Migration\n")
            f.write(f"-- Generated on: {datetime.now().isoformat()}\n")
            f.write(f"-- Total statements: {len(self.all_updates)}\n")
            f.write("USE `ojs33_gc2`;\nSET NAMES utf8mb4;\nSTART TRANSACTION;\n\n")
            for stmt in self.all_updates:
                f.write(stmt + "\n")
            f.write("\nCOMMIT;\n")
        print(f"[+] Standalone SQL migration script saved to: {sql_export_path}")

        return total_repaired

    def verify_clean(self):
        print("\n=== Verifying Database Integrity Post-Cleaning ===")
        tables = [
            ('citations', 'raw_citation'),
            ('publication_settings', 'setting_value'),
            ('author_settings', 'setting_value'),
            ('journal_settings', 'setting_value'),
            ('user_settings', 'setting_value'),
            ('notes', 'contents'),
            ('metadata_description_settings', 'setting_value'),
            ('citation_settings', 'setting_value'),
            ('controlled_vocab_entry_settings', 'setting_value'),
            ('navigation_menu_item_settings', 'setting_value'),
            ('event_log_settings', 'setting_value'),
            ('review_form_responses', 'response_value'),
            ('rt_searches', 'title'),
            ('rt_searches', 'description'),
            ('genre_settings', 'setting_value'),
            ('email_templates_default_data', 'subject'),
            ('email_templates_default_data', 'body'),
            ('email_log', 'subject'),
            ('email_log', 'body'),
            ('submission_search_keyword_list', 'keyword_text')
        ]
        
        all_passed = True
        for tbl, col in tables:
            q = f"SELECT count(*) FROM `{tbl}` WHERE CAST(`{col}` AS BINARY) LIKE '%â€%' OR CAST(`{col}` AS BINARY) LIKE '%Ã%';"
            try:
                cnt = int(self.run_query(q).strip())
                if cnt == 0:
                    print(f"    [OK] `{tbl}`.`{col}`: 0 Mojibake remaining.")
                else:
                    print(f"    [FAIL] `{tbl}`.`{col}`: {cnt} Mojibake remaining!")
                    all_passed = False
            except Exception as e:
                print(f"    [!] Error verifying `{tbl}`: {e}")
                all_passed = False

        if all_passed:
            print("\n[SUCCESS] ALL targeted tables are 100% clean and free of Mojibake!")
        else:
            print("\n[WARNING] Some tables still contain residual Mojibake. Please review above logs.")

if __name__ == '__main__':
    fixer = OJSDBFixer()
    fixer.execute_all()
    fixer.verify_clean()
