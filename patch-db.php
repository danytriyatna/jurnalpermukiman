<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
if ($token !== 'jp_fix_2026_valarie') {
    http_response_code(403);
    exit;
}

$results = [];

// Search files in cache directory
$it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator('/var/www/html/cache'));
foreach ($it as $file) {
    if ($file->isFile()) {
        $path = $file->getPathname();
        $content = @file_get_contents($path);
        if ($content && strpos($content, 'flowchart-publication-procedure') !== false) {
            $results[] = [
                'path' => $path,
                'snippet' => substr($content, strpos($content, 'flowchart-publication-procedure') - 50, 150)
            ];
            // delete the cache file!
            @unlink($path);
        }
    }
}

// Also delete all files in /var/www/html/cache/t_compile
$it2 = new RecursiveIteratorIterator(new RecursiveDirectoryIterator('/var/www/html/cache/t_compile', RecursiveDirectoryIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
$delCount = 0;
foreach ($it2 as $f) {
    if ($f->isDir()) {
        @rmdir($f->getRealPath());
    } else {
        @unlink($f->getRealPath());
        $delCount++;
    }
}

echo json_encode([
    'cached_files_found' => $results,
    't_compile_files_deleted' => $delCount
], JSON_PRETTY_PRINT);
