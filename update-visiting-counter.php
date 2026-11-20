<?php
/**
 * Direct Patch for Visiting Counter without collation conflicts
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

    $flagUrl = 'https://s01.flagcounter.com/count2/Pf4A/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_10/viewers_0/labels_0/pageviews_0/flags_0/percent_0/';
    $updated = [];

    // 1. Target plugin_settings for custom blocks
    $stmt = $pdo->query("SELECT plugin_name, context_id, setting_name, setting_value FROM plugin_settings WHERE setting_name = 'blockContent'");
    $rows = $stmt->fetchAll();

    foreach ($rows as $row) {
        $val = $row['setting_value'];
        if (strpos($val, 'flagcounter') !== false) {
            $newVal = str_replace($flagUrl, '/visitor-counter.php', $val);
            // also replace any flagcounter today link to statcounter
            $newVal = str_replace('https://s01.flagcounter.com/today/Pf4A/', 'https://statcounter.com/p12885777/?guest=1', $newVal);

            $u = $pdo->prepare("UPDATE plugin_settings SET setting_value = :val WHERE plugin_name = :p AND context_id = :c AND setting_name = :s");
            $u->execute([
                ':val' => $newVal,
                ':p' => $row['plugin_name'],
                ':c' => $row['context_id'],
                ':s' => $row['setting_name'],
            ]);
            $updated[] = [
                'type' => 'plugin_settings',
                'plugin' => $row['plugin_name'],
                'context' => $row['context_id']
            ];
        }
    }

    // 2. Target navigation_menu_item_settings
    $stmt2 = $pdo->query("SELECT navigation_menu_item_id, setting_name, setting_value FROM navigation_menu_item_settings WHERE setting_name = 'content'");
    $rows2 = $stmt2->fetchAll();

    foreach ($rows2 as $row) {
        $val = $row['setting_value'];
        if (strpos($val, 'flagcounter') !== false) {
            $newVal = str_replace($flagUrl, '/visitor-counter.php', $val);
            $newVal = str_replace('https://s01.flagcounter.com/today/Pf4A/', 'https://statcounter.com/p12885777/?guest=1', $newVal);

            $u2 = $pdo->prepare("UPDATE navigation_menu_item_settings SET setting_value = :val WHERE navigation_menu_item_id = :id AND setting_name = :s");
            $u2->execute([
                ':val' => $newVal,
                ':id' => $row['navigation_menu_item_id'],
                ':s' => $row['setting_name'],
            ]);
            $updated[] = [
                'type' => 'navigation_menu_item_settings',
                'id' => $row['navigation_menu_item_id']
            ];
        }
    }

    // 3. Clear template cache
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
        'cache_cleared' => $cleared
    ], JSON_PRETTY_PRINT);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
