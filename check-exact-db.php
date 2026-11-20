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

// Show DB config
$dbConf = $config['database'] ?? [];
unset($dbConf['password']); // hide password

// Connect using exact config
$dsn = "mysql:host={$dbConf['host']};port=" . ($dbConf['port'] ?? '3306') . ";dbname={$dbConf['name']};charset=utf8mb4";
$pdo = new PDO($dsn, $config['database']['username'], $config['database']['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

// List all databases on MySQL server
$dbs = $pdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);

// In current DB, find what static pages exist and where flowchart exists
$flowInDb = $pdo->query("SELECT static_page_id, locale, setting_name, SUBSTRING(setting_value, 1, 150) as val, setting_value FROM static_page_settings WHERE setting_value LIKE '%flowchart%'")->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
    'dbConfig' => $dbConf,
    'allDatabases' => $dbs,
    'flowInDb' => $flowInDb
], JSON_PRETTY_PRINT);
