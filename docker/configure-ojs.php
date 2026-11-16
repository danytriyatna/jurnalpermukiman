<?php
/**
 * Generate /var/www/html/config.inc.php dari config.TEMPLATE.inc.php
 * menggunakan environment variables container pada saat startup.
 */

$skip = getenv('OJS_SKIP_AUTO_CONFIG');
$targetFile = '/var/www/html/config.inc.php';
$templateFile = '/var/www/html/config.TEMPLATE.inc.php';

if ($skip === '1' || $skip === 'true') {
    if (file_exists($targetFile)) {
        exit(0);
    }
}

if (!file_exists($templateFile)) {
    fwrite(STDERR, "Template config.TEMPLATE.inc.php tidak ditemukan.\n");
    exit(1);
}

$envOr = static function (string $key, string $default): string {
    $val = getenv($key);
    return ($val !== false && trim($val) !== '') ? trim($val) : $default;
};

$updates = [
    'general' => [
        'installed' => $envOr('OJS_INSTALLED', 'On'),
        'base_url' => rtrim($envOr('OJS_BASE_URL', 'http://localhost'), '/'),
        'time_zone' => $envOr('OJS_TIME_ZONE', 'Asia/Jakarta'),
        'allowed_hosts' => $envOr('OJS_ALLOWED_HOSTS', ''),
        'trust_x_forwarded_for' => $envOr('OJS_TRUST_PROXY', 'Off'),
        'restful_urls' => $envOr('OJS_RESTFUL_URLS', 'Off'),
    ],
    'database' => [
        'driver' => $envOr('OJS_DB_DRIVER', 'mysqli'),
        'host' => $envOr('OJS_DB_HOST', 'jp-mariadb'),
        'port' => $envOr('OJS_DB_PORT', '3306'),
        'username' => $envOr('OJS_DB_USER', 'ojs'),
        'password' => $envOr('OJS_DB_PASSWORD', ''),
        'name' => $envOr('OJS_DB_NAME', 'ojs'),
        'collation' => $envOr('OJS_DB_COLLATION', 'utf8mb4_unicode_ci'),
    ],
    'i18n' => [
        'client_charset' => 'utf-8',
        'connection_charset' => 'utf8mb4',
        'charset_normalization' => 'On',
    ],
    'files' => [
        'files_dir' => $envOr('OJS_FILES_DIR', '/var/www/files_dir'),
        'public_files_dir' => 'public',
    ],
    'security' => [
        'force_ssl' => $envOr('OJS_FORCE_SSL', 'Off'),
        'force_login_ssl' => $envOr('OJS_FORCE_SSL', 'Off'),
        'session_check_ip' => $envOr('OJS_SESSION_CHECK_IP', 'On'),
        'salt' => $envOr('OJS_SALT', 'YouMustSetASecretKeyHere!!'),
        'api_key_secret' => $envOr('OJS_API_KEY_SECRET', ''),
    ],
    'mqc' => [
        'api_url' => $envOr('OJS_MQC_API_URL', 'http://jp-mqc:3000/api/check-submission'),
        'api_key' => $envOr('OJS_MQC_API_KEY', ''),
    ],
    'jp_insight' => [
        'widget_endpoint' => $envOr('JP_INSIGHT_WIDGET_ENDPOINT', 'http://localhost:3001/api/widget/chat'),
    ],
];

$formatValue = static function (string $key, string $val): string {
    if ($key === 'allowed_hosts') {
        $escapedSingle = str_replace("'", "\\'", $val);
        return "'" . $escapedSingle . "'";
    }
    $bareKeys = [
        'installed', 'trust_x_forwarded_for', 'restful_urls', 'port',
        'charset_normalization', 'force_ssl', 'force_login_ssl', 'session_check_ip',
    ];
    if (in_array($key, $bareKeys, true) && preg_match('/^(On|Off|[0-9]+)$/i', $val)) {
        return $val;
    }
    $escaped = str_replace(['\\', '"'], ['\\\\', '\\"'], $val);
    return '"' . $escaped . '"';
};

$lines = file($templateFile, FILE_IGNORE_NEW_LINES);
$written = [];
$currentSection = '';
$out = [];

foreach ($lines as $line) {
    if (preg_match('/^\s*\[([a-zA-Z0-9_]+)\]\s*$/', $line, $m)) {
        $currentSection = $m[1];
        $out[] = $line;
        continue;
    }

    if ($currentSection !== '' && isset($updates[$currentSection])) {
        if (preg_match('/^\s*(?:;\s*)?([a-zA-Z0-9_]+)\s*=/', $line, $m)) {
            $key = $m[1];
            if (array_key_exists($key, $updates[$currentSection])) {
                $out[] = $key . ' = ' . $formatValue($key, $updates[$currentSection][$key]);
                $written[$currentSection][$key] = true;
                continue;
            }
        }
    }

    $out[] = $line;
}

foreach ($updates as $section => $kv) {
    $pending = [];
    foreach ($kv as $key => $val) {
        if (empty($written[$section][$key])) {
            $pending[] = $key . ' = ' . $formatValue($key, $val);
        }
    }
    if (!empty($pending)) {
        $out[] = '';
        $out[] = '[' . $section . ']';
        foreach ($pending as $p) {
            $out[] = $p;
        }
    }
}

file_put_contents($targetFile, implode(PHP_EOL, $out) . PHP_EOL);
@chmod($targetFile, 0640);
@chgrp($targetFile, 'www-data');
