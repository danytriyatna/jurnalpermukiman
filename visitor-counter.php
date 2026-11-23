<?php
/**
 * Local Cached Proxy for Visitor Flag Counter
 * Prevents adblocker blockage, external network latency, and DNS failures.
 */

// Define local cache file
$cacheDir = __DIR__ . '/cache';
if (!is_dir($cacheDir)) {
    @mkdir($cacheDir, 0777, true);
}
$cacheFile = $cacheDir . '/flag_counter_cached.png';

// Fallback image bundled locally in repo if available
$bundledFallback = __DIR__ . '/public/site/images/visitor-counter.png';

$remoteUrl = 'https://s01.flagcounter.com/count2/Pf4A/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_10/viewers_0/labels_0/pageviews_0/flags_0/percent_0/';

// Refresh cache if older than 5 minutes (300 seconds) or non-existent
$needsFetch = !file_exists($cacheFile) || (time() - filemtime($cacheFile) > 300);

if ($needsFetch) {
    $ctx = stream_context_create([
        'http' => [
            'timeout' => 3,
            'user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        ],
        'ssl' => [
            'verify_peer' => true,
            'verify_peer_name' => true,
        ]
    ]);
    $remoteData = @file_get_contents($remoteUrl, false, $ctx);
    if ($remoteData !== false && strlen($remoteData) > 500) {
        @file_put_contents($cacheFile, $remoteData);
    }
}

// Serve cache if exists
if (file_exists($cacheFile) && filesize($cacheFile) > 500) {
    header('Content-Type: image/png');
    header('Content-Length: ' . filesize($cacheFile));
    header('Cache-Control: public, max-age=120, stale-while-revalidate=600');
    header('X-Content-Type-Options: nosniff');
    readfile($cacheFile);
    exit;
}

// Serve bundled fallback if cache fetch failed
if (file_exists($bundledFallback) && filesize($bundledFallback) > 500) {
    header('Content-Type: image/png');
    header('Content-Length: ' . filesize($bundledFallback));
    header('Cache-Control: public, max-age=60');
    header('X-Content-Type-Options: nosniff');
    readfile($bundledFallback);
    exit;
}

// Last resort redirect
header('Location: ' . $remoteUrl);
exit;
