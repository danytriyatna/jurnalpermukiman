<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
if ($token !== 'jp_fix_2026_valarie') {
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
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB Connection failed: ' . $e->getMessage()]);
    exit;
}

$updates = [];

// 1. Update navigation_menu_item_settings
$stmt1 = $pdo->prepare("
    UPDATE navigation_menu_item_settings
    SET setting_value = REPLACE(
        REPLACE(
            REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/'),
            'https://jurnalpermukiman.pu.go.id/public/', '/public/'
        ),
        'http://jurnalpermukiman.pu.go.id/public/', '/public/'
    )
    WHERE setting_value LIKE '%flowchart-publication-procedure%'
");
$stmt1->execute();
$updates['navigation_menu_item_settings_affected'] = $stmt1->rowCount();

// 2. Update static_page_settings just in case
$stmt2 = $pdo->prepare("
    UPDATE static_page_settings
    SET setting_value = REPLACE(
        REPLACE(
            REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/'),
            'https://jurnalpermukiman.pu.go.id/public/', '/public/'
        ),
        'http://jurnalpermukiman.pu.go.id/public/', '/public/'
    )
    WHERE setting_value LIKE '%flowchart-publication-procedure%'
");
$stmt2->execute();
$updates['static_page_settings_affected'] = $stmt2->rowCount();

// 3. Update journal_settings
$stmt3 = $pdo->prepare("
    UPDATE journal_settings
    SET setting_value = REPLACE(
        REPLACE(
            REPLACE(setting_value, '//jurnalpermukiman.pu.go.id/public/', '/public/'),
            'https://jurnalpermukiman.pu.go.id/public/', '/public/'
        ),
        'http://jurnalpermukiman.pu.go.id/public/', '/public/'
    )
    WHERE setting_value LIKE '%flowchart-publication-procedure%'
");
$stmt3->execute();
$updates['journal_settings_affected'] = $stmt3->rowCount();

// Check the exact value of navigation_menu_item_id = 29 now
$chk = $pdo->query("
    SELECT navigation_menu_item_id, locale, setting_name, SUBSTRING(setting_value, -300) as snippet
    FROM navigation_menu_item_settings
    WHERE navigation_menu_item_id = 29 AND setting_name = 'content'
")->fetchAll();
$updates['item_29_verification'] = $chk;

// Clear all OJS compile cache and data cache
$cacheDir = '/var/www/html/cache';
$delCount = 0;
if (is_dir($cacheDir . '/t_compile')) {
    $it = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($cacheDir . '/t_compile', RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::CHILD_FIRST
    );
    foreach ($it as $f) {
        if ($f->isDir()) {
            @rmdir($f->getRealPath());
        } else {
            @unlink($f->getRealPath());
            $delCount++;
        }
    }
}

// Clear _db cache
if (is_dir($cacheDir . '/_db')) {
    $itDb = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($cacheDir . '/_db', RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::CHILD_FIRST
    );
    foreach ($itDb as $f) {
        if ($f->isFile()) {
            @unlink($f->getRealPath());
            $delCount++;
        }
    }
}

// Clear .php cache files directly in /var/www/html/cache
foreach (glob($cacheDir . '/*.php') as $phpCache) {
    @unlink($phpCache);
    $delCount++;
}

$updates['cache_files_deleted'] = $delCount;

echo json_encode([
    'success' => true,
    'updates' => $updates
], JSON_PRETTY_PRINT);
