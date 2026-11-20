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

    // Search ALL tables in database for 'flowchart-publication-procedure'
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    $foundIn = [];

    foreach ($tables as $table) {
        $cols = $pdo->query("SHOW COLUMNS FROM `$table`")->fetchAll(PDO::FETCH_ASSOC);
        $textCols = [];
        foreach ($cols as $c) {
            $type = strtolower($c['Type']);
            if (strpos($type, 'char') !== false || strpos($type, 'text') !== false || strpos($type, 'blob') !== false) {
                $textCols[] = $c['Field'];
            }
        }
        if (empty($textCols)) continue;

        $where = [];
        foreach ($textCols as $col) {
            $where[] = "`$col` LIKE '%flowchart%'";
        }
        $sql = "SELECT * FROM `$table` WHERE " . implode(' OR ', $where);
        try {
            $rows = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);
            if (!empty($rows)) {
                $foundIn[$table] = $rows;
            }
        } catch (Exception $e) {
            // skip table if query fails
        }
    }

    echo json_encode($foundIn, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
