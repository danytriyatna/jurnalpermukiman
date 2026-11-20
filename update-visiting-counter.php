<?php
/**
 * One-time update script for customblock-data-kunjungan
 * Replaces direct external flagcounter.com links with internal /visitor-counter.php
 */

$isCli = (php_sapi_name() === 'cli');
$token = $_GET['token'] ?? ($argv[1] ?? '');
if (!$isCli && $token !== 'jp_fix_2026_valarie') {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden']);
    exit;
}

$configFile = __DIR__ . '/config.inc.php';
if (!file_exists($configFile)) {
    http_response_code(500);
    echo json_encode(['error' => 'config.inc.php not found']);
    exit;
}

$config = parse_ini_file($configFile, true);
$dbConf = $config['database'];

try {
    $dsn = "mysql:host={$dbConf['host']};port=" . ($dbConf['port'] ?? '3306') . ";dbname={$dbConf['name']};charset=utf8mb4";
    $pdo = new PDO($dsn, $dbConf['username'], $dbConf['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    // Check plugin_settings
    $stmt = $pdo->query("SELECT plugin_name, locale, setting_name, setting_value FROM plugin_settings WHERE setting_value LIKE '%flagcounter%'");
    $rows = $stmt->fetchAll();

    $updated = [];
    foreach ($rows as $row) {
        $oldVal = $row['setting_value'];
        
        // Target replacement of flagcounter markup
        $pattern = '/<p[^>]*><a[^>]*flagcounter[^>]*>.*?<\/a><\/p>/is';
        $newCounterHtml = '<p class="jp-counter-row"><a href="https://statcounter.com/p12885777/?guest=1" target="_blank" rel="noopener" class="jp-counter-badge"><img src="/visitor-counter.php" alt="Statistik Pengunjung Jurnal Permukiman" class="jp-counter-img" /></a></p>';
        
        if (preg_match($pattern, $oldVal)) {
            $newVal = preg_replace($pattern, $newCounterHtml, $oldVal);
        } else {
            // direct replace of img/a if not in p
            $newVal = str_replace(
                'https://s01.flagcounter.com/count2/Pf4A/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_10/viewers_0/labels_0/pageviews_0/flags_0/percent_0/',
                '/visitor-counter.php',
                $oldVal
            );
        }

        $uStmt = $pdo->prepare("UPDATE plugin_settings SET setting_value = :val WHERE plugin_name = :pname AND setting_name = :sname AND locale = :locale");
        $uStmt->execute([
            ':val' => $newVal,
            ':pname' => $row['plugin_name'],
            ':sname' => $row['setting_name'],
            ':locale' => $row['locale'],
        ]);
        $updated[] = [
            'plugin_name' => $row['plugin_name'],
            'setting_name' => $row['setting_name'],
            'locale' => $row['locale']
        ];
    }

    // Also check any navigation_menu_item_settings or custom blocks
    $stmt2 = $pdo->query("SELECT navigation_menu_item_id, setting_name, setting_value FROM navigation_menu_item_settings WHERE setting_value LIKE '%flagcounter%'");
    $rows2 = $stmt2->fetchAll();
    foreach ($rows2 as $row) {
        $oldVal = $row['setting_value'];
        $newVal = str_replace(
            'https://s01.flagcounter.com/count2/Pf4A/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_10/viewers_0/labels_0/pageviews_0/flags_0/percent_0/',
            '/visitor-counter.php',
            $oldVal
        );
        $uStmt2 = $pdo->prepare("UPDATE navigation_menu_item_settings SET setting_value = :val WHERE navigation_menu_item_id = :id AND setting_name = :sname");
        $uStmt2->execute([
            ':val' => $newVal,
            ':id' => $row['navigation_menu_item_id'],
            ':sname' => $row['setting_name'],
        ]);
        $updated[] = [
            'nav_id' => $row['navigation_menu_item_id'],
            'setting_name' => $row['setting_name']
        ];
    }

    // Clear template cache
    $cacheDirs = [
        __DIR__ . '/cache/t_compile',
        __DIR__ . '/cache/t_cache',
        __DIR__ . '/cache/_db',
    ];
    $cleared = 0;
    foreach ($cacheDirs as $dir) {
        if (is_dir($dir)) {
            $files = glob($dir . '/*');
            foreach ($files as $file) {
                if (is_file($file)) {
                    @unlink($file);
                    $cleared++;
                }
            }
        }
    }

    header('Content-Type: application/json');
    echo json_encode([
        'status' => 'success',
        'updated_records' => $updated,
        'cache_cleared_files' => $cleared
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
