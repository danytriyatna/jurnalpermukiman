<?php
/**
 * Universal Database Patch for Visiting Counter
 * Replaces external flagcounter URLs with local /visitor-counter.php across all tables
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

    // Search all text columns across all tables for flagcounter
    $colStmt = $pdo->query("SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND DATA_TYPE IN ('text', 'mediumtext', 'longtext', 'varchar')");
    $columns = $colStmt->fetchAll();

    $updated = [];
    $flagUrl = 'https://s01.flagcounter.com/count2/Pf4A/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_10/viewers_0/labels_0/pageviews_0/flags_0/percent_0/';

    foreach ($columns as $c) {
        $tbl = $c['TABLE_NAME'];
        $col = $c['COLUMN_NAME'];

        // Check if table has flagcounter
        $check = $pdo->query("SELECT COUNT(*) FROM `{$tbl}` WHERE `{$col}` LIKE '%flagcounter%'")->fetchColumn();
        if ($check > 0) {
            $uSql = "UPDATE `{$tbl}` SET `{$col}` = REPLACE(`{$col}`, '{$flagUrl}', '/visitor-counter.php') WHERE `{$col}` LIKE '%flagcounter%'";
            $affected = $pdo->exec($uSql);
            $updated[] = [
                'table' => $tbl,
                'column' => $col,
                'affected_rows' => $affected
            ];
        }
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
        'updated_tables' => $updated,
        'cache_cleared' => $cleared
    ], JSON_PRETTY_PRINT);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
