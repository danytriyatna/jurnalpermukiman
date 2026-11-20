<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
if ($token !== 'jp_fix_2026_valarie') {
    http_response_code(403);
    exit;
}

$dirs = [
    '/var/www/html/cache/t_compile',
    '/var/www/html/cache/t_cache',
    '/var/www/html/cache/_db',
    '/var/www/html/cache'
];

$deleted = 0;
foreach ($dirs as $dir) {
    if (is_dir($dir)) {
        $it = new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS);
        $files = new RecursiveIteratorIterator($it, RecursiveIteratorIterator::CHILD_FIRST);
        foreach ($files as $file) {
            if ($file->isDir()) {
                @rmdir($file->getRealPath());
            } else {
                @unlink($file->getRealPath());
                $deleted++;
            }
        }
    }
}

if (function_exists('opcache_reset')) {
    opcache_reset();
}

echo json_encode([
    'status' => 'cache_cleared',
    'files_deleted' => $deleted
], JSON_PRETTY_PRINT);
