<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
$expectedToken = 'jp_fix_2026_valarie';

if ($token !== $expectedToken) {
    http_response_code(403);
    echo json_encode(['error' => 'Unauthorized']);
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
    $pdo = new PDO($dsn, $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    $results = [];

    // Find all static pages with path 'peer-review-process'
    $stmt = $pdo->query("SELECT static_page_id, path FROM static_pages WHERE path = 'peer-review-process'");
    $pages = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $results['found_pages'] = $pages;

    // Direct string replacement on all static_page_settings content
    $replaces = [
        "UPDATE static_page_settings SET setting_value = REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/')",
        "UPDATE static_page_settings SET setting_value = REPLACE(setting_value, 'https://jurnalpermukiman.pu.go.id/public/', '/public/')",
        "UPDATE static_page_settings SET setting_value = REPLACE(setting_value, 'http://jurnalpermukiman.pu.go.id/public/', '/public/')",
        "UPDATE static_page_settings SET setting_value = REPLACE(setting_value, 'jurnalpermukiman.pu.go.id/public/', '/public/')"
    ];

    $totalUpdated = 0;
    foreach ($replaces as $sql) {
        $uStmt = $pdo->prepare($sql);
        $uStmt->execute();
        $totalUpdated += $uStmt->rowCount();
    }
    $results['static_page_settings_rows_affected'] = $totalUpdated;

    // Check what the setting_value actually contains right now
    $chk = $pdo->query("SELECT static_page_id, locale, setting_name, SUBSTRING(setting_value, -300) as snippet FROM static_page_settings WHERE setting_name = 'content' AND static_page_id IN (SELECT static_page_id FROM static_pages WHERE path = 'peer-review-process')");
    $results['current_snippets'] = $chk->fetchAll(PDO::FETCH_ASSOC);

    // Also update journal_settings for copyrightNotice
    $uCopy = $pdo->prepare("UPDATE journal_settings SET setting_value = REPLACE(setting_value, 'Download Copyright Transfer Agreement Form', 'Download Copyright and License Agreement') WHERE setting_name = 'copyrightNotice'");
    $uCopy->execute();
    $results['copyright_transfer_updated'] = $uCopy->rowCount();

    // Clear all template cache files
    $files = glob('/var/www/html/cache/*.php') ?: [];
    $files = array_merge($files, glob('/var/www/html/cache/t_compile/*.php') ?: []);
    $files = array_merge($files, glob('/var/www/html/cache/t_cache/*.php') ?: []);
    $files = array_merge($files, glob('/var/www/html/cache/_db/*') ?: []);
    $cleared = 0;
    foreach ($files as $f) {
        if (is_file($f)) {
            @unlink($f);
            $cleared++;
        }
    }
    $results['cache_files_cleared'] = $cleared;
    $results['status'] = 'success';

    echo json_encode($results, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
