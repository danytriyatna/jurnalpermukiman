<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
if ($token !== 'jp_fix_2026_valarie') {
    http_response_code(403);
    exit;
}

$configFile = __DIR__ . '/config.inc.php';
$config = parse_ini_file($configFile, true);
$dbHost = $config['database']['host'] ?? 'localhost';
$dbPort = $config['database']['port'] ?? '3306';
$dbUser = $config['database']['username'] ?? 'root';
$dbPass = $config['database']['password'] ?? '';
$dbName = $config['database']['name'] ?? 'ojs33_gc2';

try {
    $dsn = "mysql:host={$dbHost};port={$dbPort};dbname={$dbName};charset=utf8mb4";
    $pdo = new PDO($dsn, $dbUser, $dbPass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    $results = [];

    // Find ALL tables and columns containing 'flowchart-publication-procedure'
    $tables = ['static_page_settings', 'journal_settings', 'section_settings', 'navigation_menu_item_settings', 'custom_issue_orders'];
    $found = [];

    // 1. Check static_page_settings
    $stmt1 = $pdo->query("SELECT static_page_id, locale, setting_name, SUBSTRING(setting_value, 1, 150) as val, setting_value FROM static_page_settings WHERE setting_value LIKE '%flowchart%'");
    $rows1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);
    $found['static_page_settings'] = $rows1;

    // 2. Check journal_settings
    $stmt2 = $pdo->query("SELECT locale, setting_name, SUBSTRING(setting_value, 1, 150) as val FROM journal_settings WHERE setting_value LIKE '%flowchart%'");
    $rows2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    $found['journal_settings'] = $rows2;

    // REPLACE in ANY table where it exists
    $pdo->exec("UPDATE static_page_settings SET setting_value = REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/') WHERE setting_value LIKE '%flowchart%'");
    $pdo->exec("UPDATE journal_settings SET setting_value = REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/') WHERE setting_value LIKE '%flowchart%'");

    // All static_pages list
    $allPages = $pdo->query("SELECT * FROM static_pages")->fetchAll(PDO::FETCH_ASSOC);
    $found['all_static_pages'] = $allPages;

    // Clear APCu and OJS files
    if (function_exists('apcu_clear_cache')) {
        @apcu_clear_cache();
    }
    if (function_exists('opcache_reset')) {
        @opcache_reset();
    }

    echo json_encode($found, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
