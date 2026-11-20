<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
if ($token !== 'jp_fix_2026_valarie') {
    http_response_code(403);
    exit;
}

// Bootstrap OJS
require_once __DIR__ . '/lib/pkp/includes/bootstrap.inc.php';

$request = Application::get()->getRequest();
$context = $request->getContext();
$contextId = $context ? $context->getId() : 1;

$dao = DAORegistry::getDAO('StaticPagesDAO');
$sp = $dao->getByPath($contextId, 'peer-review-process');

$info = [
    'contextId' => $contextId,
    'sp_found' => (bool)$sp,
    'sp_id' => $sp ? $sp->getId() : null,
    'sp_path' => $sp ? $sp->getPath() : null,
    'title_en' => $sp ? $sp->getTitle('en_US') : null,
    'content_en' => $sp ? substr((string)$sp->getContent('en_US'), -300) : null,
    'content_id' => $sp ? substr((string)$sp->getContent('id_ID'), -300) : null,
    'localized_content' => $sp ? substr((string)$sp->getLocalizedContent(), -300) : null,
];

// Let's also check if there is ANY handler in OJS matching peer-review-process!
$router = $request->getRouter();
$info['router_class'] = get_class($router);

echo json_encode($info, JSON_PRETTY_PRINT);
