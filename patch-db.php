<?php
declare(strict_types=1);

/**
 * Script migrasi otomatis untuk memperbaiki database & cache OJS di VPS.
 * Mengganti path gambar absolut domain lama menjadi path relatif /public/
 * dan menghapus kata Transfer dari copyright notice.
 */

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
$expectedToken = 'jp_fix_2026_valarie';

if ($token !== $expectedToken) {
    http_response_code(403);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

$configFile = __DIR__ . '/config.inc.php';
if (!file_exists($configFile)) {
    http_response_code(500);
    echo json_encode(['error' => 'config.inc.php not found']);
    exit;
}

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

    // 1. Fix domain absolut di static_page_settings
    $stmt1 = $pdo->prepare("UPDATE static_page_settings SET setting_value = REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/') WHERE setting_name = 'content'");
    $stmt1->execute();
    $results['static_pages_updated'] = $stmt1->rowCount();

    // 2. Fix kata Transfer di copyrightNotice
    $stmt2 = $pdo->prepare("UPDATE journal_settings SET setting_value = REPLACE(setting_value, 'Download Copyright Transfer Agreement Form', 'Download Copyright and License Agreement') WHERE setting_name = 'copyrightNotice'");
    $stmt2->execute();
    $results['copyright_transfer_replaced'] = $stmt2->rowCount();

    // 3. Pastikan peer-review-process static page terdaftar
    $chkStmt = $pdo->query("SELECT static_page_id FROM static_pages WHERE path = 'peer-review-process' AND context_id = 1 LIMIT 1");
    $existing = $chkStmt->fetch(PDO::FETCH_ASSOC);
    if (!$existing) {
        $insStmt = $pdo->prepare("INSERT INTO static_pages (path, context_id) VALUES ('peer-review-process', 1)");
        $insStmt->execute();
        $newId = (int)$pdo->lastInsertId();
        $results['peer_review_page_inserted'] = $newId;
    } else {
        $results['peer_review_page_exists'] = (int)$existing['static_page_id'];
    }

    // 4. Bersihkan cache template
    $cacheDirs = [
        __DIR__ . '/cache',
        __DIR__ . '/cache/t_compile',
        __DIR__ . '/cache/t_cache'
    ];
    $cleared = 0;
    foreach ($cacheDirs as $dir) {
        if (is_dir($dir)) {
            $files = glob($dir . '/*.php') ?: [];
            foreach ($files as $file) {
                if (is_file($file)) {
                    @unlink($file);
                    $cleared++;
                }
            }
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
