<?php
declare(strict_types=1);

/**
 * Proxy same-origin untuk widget chat JP-Insight di portal OJS.
 * Memungkinkan browser mengirim pertanyaan ke origin OJS sendiri ('self') sesuai
 * aturan Content-Security-Policy (connect-src 'self') lalu meneruskannya ke
 * layanan JP-Insight lewat jaringan internal Docker / fallback URL publik.
 */

const JP_WIDGET_PROXY_MAX_BODY_BYTES = 16384;
const JP_WIDGET_PROXY_CONNECT_TIMEOUT_SEC = 5;
const JP_WIDGET_PROXY_TIMEOUT_SEC = 55;

function jp_widget_normalize_origin(?string $raw): ?string {
    if ($raw === null) {
        return null;
    }
    $trimmed = trim($raw);
    if ($trimmed === '' || strtolower($trimmed) === 'null') {
        return null;
    }
    $parts = @parse_url($trimmed);
    if (!is_array($parts) || empty($parts['scheme']) || empty($parts['host'])) {
        return null;
    }
    $scheme = strtolower((string) $parts['scheme']);
    if ($scheme !== 'http' && $scheme !== 'https') {
        return null;
    }
    $host = strtolower((string) $parts['host']);
    $origin = $scheme . '://' . $host;
    if (!empty($parts['port'])) {
        $port = (int) $parts['port'];
        $isDefaultPort = ($scheme === 'http' && $port === 80) || ($scheme === 'https' && $port === 443);
        if (!$isDefaultPort) {
            $origin .= ':' . $port;
        }
    }
    return $origin;
}

function jp_widget_add_loopback_sibling(string $origin, array &$allowed): void {
    $parts = @parse_url($origin);
    if (!is_array($parts) || empty($parts['scheme']) || empty($parts['host'])) {
        return;
    }
    $host = strtolower((string) $parts['host']);
    $portSuffix = !empty($parts['port']) ? ':' . (int) $parts['port'] : '';
    if ($host === 'localhost') {
        $allowed[] = strtolower((string) $parts['scheme']) . '://127.0.0.1' . $portSuffix;
    } elseif ($host === '127.0.0.1') {
        $allowed[] = strtolower((string) $parts['scheme']) . '://localhost' . $portSuffix;
    }
}

/**
 * Membaca config.inc.php secara ringan tanpa bootstrap full OJS.
 *
 * @return array<string, mixed>
 */
function jp_widget_read_ojs_ini(?string $configPath = null): array {
    $path = $configPath ?? (__DIR__ . '/config.inc.php');
    if (!is_file($path) || !is_readable($path)) {
        return [];
    }
    $parsed = @parse_ini_file($path, true, INI_SCANNER_RAW);
    return is_array($parsed) ? $parsed : [];
}

/**
 * Memastikan permintaan berasal dari origin OJS sendiri (mencegah lintas situs).
 *
 * @param array<string, mixed> $server
 * @param array<string, mixed> $ini
 * @return array{allowed: bool, error?: string}
 */
function jp_widget_evaluate_same_origin(array $server, array $ini = []): array {
    $fetchSite = strtolower(trim((string) ($server['HTTP_SEC_FETCH_SITE'] ?? '')));
    if ($fetchSite === 'cross-site') {
        return ['allowed' => false, 'error' => 'Permintaan lintas situs tidak diizinkan.'];
    }

    $rawOrigin = trim((string) ($server['HTTP_ORIGIN'] ?? ''));
    if ($rawOrigin === '') {
        return ['allowed' => true];
    }

    $normalizedOrigin = jp_widget_normalize_origin($rawOrigin);
    if ($normalizedOrigin === null) {
        return ['allowed' => false, 'error' => 'Header Origin tidak valid.'];
    }

    $allowed = [];
    $protoRaw = (string) ($server['HTTP_X_FORWARDED_PROTO'] ?? '');
    $proto = $protoRaw !== ''
        ? strtolower(trim(explode(',', $protoRaw)[0]))
        : ((!empty($server['HTTPS']) && strtolower((string) $server['HTTPS']) !== 'off') ? 'https' : 'http');

    $hostHeader = trim((string) ($server['HTTP_X_FORWARDED_HOST'] ?? ''));
    if ($hostHeader !== '') {
        $hostHeader = trim(explode(',', $hostHeader)[0]);
    } else {
        $hostHeader = trim((string) ($server['HTTP_HOST'] ?? ''));
    }

    if ($hostHeader !== '') {
        $selfOrigin = jp_widget_normalize_origin($proto . '://' . $hostHeader);
        if ($selfOrigin !== null) {
            $allowed[] = $selfOrigin;
            jp_widget_add_loopback_sibling($selfOrigin, $allowed);
        }
    }

    $envBaseUrl = getenv('OJS_BASE_URL');
    $iniBaseUrl = isset($ini['general']['base_url']) ? (string) $ini['general']['base_url'] : '';
    foreach ([$envBaseUrl ?: null, $iniBaseUrl ?: null] as $candidate) {
        $origin = jp_widget_normalize_origin($candidate);
        if ($origin !== null) {
            $allowed[] = $origin;
            jp_widget_add_loopback_sibling($origin, $allowed);
        }
    }

    $allowed = array_values(array_unique($allowed));
    if (!in_array($normalizedOrigin, $allowed, true)) {
        return ['allowed' => false, 'error' => 'Origin tidak diizinkan mengakses proxy widget.'];
    }

    return ['allowed' => true];
}

/**
 * Mengekstrak IP pengunjung asli untuk diteruskan ke rate-limiter JP-Insight.
 *
 * @param array<string, mixed> $server
 */
function jp_widget_resolve_client_ip(array $server): ?string {
    $cf = trim((string) ($server['HTTP_CF_CONNECTING_IP'] ?? ''));
    $xff = '';
    if (!empty($server['HTTP_X_FORWARDED_FOR'])) {
        $xff = trim(explode(',', (string) $server['HTTP_X_FORWARDED_FOR'])[0]);
    }
    $realIp = trim((string) ($server['HTTP_X_REAL_IP'] ?? ''));
    $remote = trim((string) ($server['REMOTE_ADDR'] ?? ''));

    $candidate = $cf !== '' ? $cf : ($xff !== '' ? $xff : ($realIp !== '' ? $realIp : $remote));
    $clean = preg_replace('/^::ffff:/i', '', trim($candidate));
    return ($clean !== null && $clean !== '') ? $clean : null;
}

/**
 * Menyusun daftar kandidat URL upstream JP-Insight (prioritas internal Docker,
 * lalu fallback ke JP_INSIGHT_WIDGET_ENDPOINT / config.inc.php / localhost).
 *
 * @param array<string, mixed> $ini
 * @return string[]
 */
function jp_widget_resolve_upstream_targets(array $ini = [], ?bool $inDockerOverride = null): array {
    $targets = [];
    $pushUnique = static function (?string $url) use (&$targets): void {
        if ($url === null) {
            return;
        }
        $clean = trim($url);
        if ($clean === '' || !preg_match('#^https?://#i', $clean)) {
            return;
        }
        if (!in_array($clean, $targets, true)) {
            $targets[] = $clean;
        }
    };

    $internalEnv = getenv('JP_INSIGHT_INTERNAL_WIDGET_URL');
    if (is_string($internalEnv) && trim($internalEnv) !== '') {
        $pushUnique($internalEnv);
    }

    $inDocker = $inDockerOverride
        ?? (is_file('/.dockerenv') || getenv('OJS_DB_HOST') === 'jp-mariadb');
    if ($inDocker) {
        $pushUnique('http://jp-insight:3000/api/widget/chat');
    }

    $envWidget = getenv('JP_INSIGHT_WIDGET_ENDPOINT');
    if (is_string($envWidget) && trim($envWidget) !== '') {
        $pushUnique($envWidget);
    } elseif (!empty($_ENV['JP_INSIGHT_WIDGET_ENDPOINT'])) {
        $pushUnique((string) $_ENV['JP_INSIGHT_WIDGET_ENDPOINT']);
    }

    if (!empty($ini['jp_insight']['widget_endpoint'])) {
        $pushUnique((string) $ini['jp_insight']['widget_endpoint']);
    }

    $pushUnique('http://localhost:3001/api/widget/chat');

    return $targets;
}

function jp_widget_send_json(int $status, array $payload, array $extraHeaders = []): void {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    header('Vary: Origin');
    foreach ($extraHeaders as $name => $value) {
        header($name . ': ' . $value);
    }
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
}

function jp_widget_handle_request(): void {
    $method = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));
    $ini = jp_widget_read_ojs_ini();

    $originCheck = jp_widget_evaluate_same_origin($_SERVER, $ini);
    if (!$originCheck['allowed']) {
        jp_widget_send_json(403, ['error' => $originCheck['error'] ?? 'Origin tidak diizinkan.']);
        return;
    }

    if ($method !== 'POST') {
        jp_widget_send_json(405, ['error' => 'Metode permintaan harus POST.'], ['Allow' => 'POST']);
        return;
    }

    $contentLength = isset($_SERVER['CONTENT_LENGTH']) ? (int) $_SERVER['CONTENT_LENGTH'] : 0;
    if ($contentLength > JP_WIDGET_PROXY_MAX_BODY_BYTES) {
        jp_widget_send_json(413, ['error' => 'Ukuran permintaan terlalu besar.']);
        return;
    }

    $rawBody = file_get_contents('php://input', false, null, 0, JP_WIDGET_PROXY_MAX_BODY_BYTES + 1);
    if ($rawBody === false || strlen($rawBody) > JP_WIDGET_PROXY_MAX_BODY_BYTES) {
        jp_widget_send_json(413, ['error' => 'Ukuran permintaan terlalu besar.']);
        return;
    }

    $decoded = json_decode($rawBody, true);
    if (json_last_error() !== JSON_ERROR_NONE || !is_array($decoded)) {
        jp_widget_send_json(400, ['error' => 'Format permintaan harus berupa JSON yang valid.']);
        return;
    }

    $question = isset($decoded['question']) && is_string($decoded['question'])
        ? trim($decoded['question'])
        : '';
    if ($question === '') {
        jp_widget_send_json(400, ['error' => 'Pertanyaan tidak boleh kosong']);
        return;
    }

    if (!function_exists('curl_init')) {
        jp_widget_send_json(500, ['error' => 'Ekstensi cURL PHP tidak tersedia pada server OJS.']);
        return;
    }

    $targets = jp_widget_resolve_upstream_targets($ini);
    $clientIp = jp_widget_resolve_client_ip($_SERVER);
    $forwardPayload = json_encode(['question' => $question], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

    $forwardHeaders = [
        'Content-Type: application/json',
        'Accept: application/json',
        'Expect:',
    ];
    if ($clientIp !== null) {
        $forwardHeaders[] = 'X-Forwarded-For: ' . $clientIp;
    }

    foreach ($targets as $targetUrl) {
        $ch = curl_init($targetUrl);
        if ($ch === false) {
            continue;
        }

        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $forwardPayload,
            CURLOPT_HTTPHEADER => $forwardHeaders,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HEADER => true,
            CURLOPT_FOLLOWLOCATION => false,
            CURLOPT_CONNECTTIMEOUT => JP_WIDGET_PROXY_CONNECT_TIMEOUT_SEC,
            CURLOPT_TIMEOUT => JP_WIDGET_PROXY_TIMEOUT_SEC,
        ]);

        $rawResponse = curl_exec($ch);
        $curlErr = curl_errno($ch);
        $statusCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $headerSize = (int) curl_getinfo($ch, CURLINFO_HEADER_SIZE);
        curl_close($ch);

        if ($curlErr !== 0 || $rawResponse === false || $statusCode <= 0) {
            continue;
        }

        $headerBlock = substr((string) $rawResponse, 0, $headerSize);
        $body = substr((string) $rawResponse, $headerSize);

        http_response_code($statusCode);
        header('Cache-Control: no-store');
        header('Vary: Origin');

        if (preg_match('/^Content-Type:\s*([^\r\n]+)/mi', $headerBlock, $ctMatch)) {
            header('Content-Type: ' . trim($ctMatch[1]));
        } else {
            header('Content-Type: application/json; charset=utf-8');
        }

        if (preg_match('/^Retry-After:\s*([^\r\n]+)/mi', $headerBlock, $raMatch)) {
            header('Retry-After: ' . trim($raMatch[1]));
        }

        echo $body;
        return;
    }

    jp_widget_send_json(502, ['error' => 'Server asisten JP-Insight sedang tidak dapat dijangkau.']);
}

if (!defined('JP_WIDGET_PROXY_LIBRARY_ONLY') && PHP_SAPI !== 'cli') {
    jp_widget_handle_request();
}
