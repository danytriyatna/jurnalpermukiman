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

    // Query all rows in static_pages
    $sp = $pdo->query("SELECT * FROM static_pages WHERE path LIKE '%peer%'")->fetchAll(PDO::FETCH_ASSOC);

    // Query settings for all peer pages
    $sps = $pdo->query("SELECT s.static_page_id, s.path, ss.locale, ss.setting_name, SUBSTRING(ss.setting_value, -250) as snippet FROM static_pages s LEFT JOIN static_page_settings ss ON s.static_page_id = ss.static_page_id WHERE s.path LIKE '%peer%'")->fetchAll(PDO::FETCH_ASSOC);

    // Let's also check if any static_page_settings has the old domain
    $oldMatches = $pdo->query("SELECT static_page_id, setting_name, locale FROM static_page_settings WHERE setting_value LIKE '%jurnalpermukiman.pu.go.id/public/%'")->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'static_pages' => $sp,
        'settings' => $sps,
        'old_matches_count' => count($oldMatches),
        'old_matches' => $oldMatches
    ], JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
