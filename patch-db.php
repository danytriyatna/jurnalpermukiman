<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

$token = $_GET['token'] ?? '';
$expectedToken = 'jp_fix_2026_valarie';

if ($token !== $expectedToken) {
    http_response_code(403);
    echo json_encode(['error' => 'Unauthorized']);
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
    $pdo = new PDO($dsn, $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    $results = [];

    // 1. Dapatkan atau buat static page peer-review-process
    $stmt = $pdo->query("SELECT static_page_id FROM static_pages WHERE path = 'peer-review-process' AND context_id = 1 LIMIT 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        $ins = $pdo->prepare("INSERT INTO static_pages (path, context_id) VALUES ('peer-review-process', 1)");
        $ins->execute();
        $spId = (int)$pdo->lastInsertId();
    } else {
        $spId = (int)$row['static_page_id'];
    }
    $results['peer_review_sp_id'] = $spId;

    // 2. Isi konten lengkap dengan path relatif /public/ (agar gambar langsung tampil)
    $content = '<p>All manuscripts submitted to Jurnal Permukiman must comply with the journal\'s author guidelines. Upon submission, authors will receive an acknowledgment email from the editorial team. Each manuscript is initially handled by the journal secretariat, which conducts an administrative check to ensure compliance with the journal template, author guidelines, and plagiarism requirements using the designated similarity checking tools (Turnitin/iThenticate). Manuscripts with a similarity index above 20% (excluding quotations, references, and standard terminology) will be returned to the author for revision prior to proceeding to the review stage, or declined if significant indications of plagiarism are found.</p>

<p>Manuscripts that pass the administrative screening will proceed to the initial editorial evaluation and peer review process. Each manuscript then undergoes an Initial Screening conducted by the editor to ensure: (1) relevance to the journal\'s focus and scope; (2) novelty of the research; (3) proper use of citation tools and adherence to the required formatting style; (4) adequacy and relevance of references; (5) clarity and quality of language; and (6) Consistency between methodology, result and discussion.</p>

<p>Manuscripts that meet these initial requirements are anonymized and forwarded to <strong>two reviewers</strong> for a <strong>Double-Blind Peer Review</strong> process. Reviewers are assigned based on their relevant expertise and publication track record in the field related to the manuscript\'s topic (settlements, housing, infrastructure, and related fields), and must not have any conflict of interest with the author(s). The editor assigns appropriate reviewers and ensures that the review process is conducted objectively and confidentially. Reviewers evaluate the manuscript based on scientific quality, originality, methodology, results, discussion, and presentation using a structured review form. Each reviewer is expected to complete the review within a <strong>maximum of 4 (four) weeks</strong> from the date the manuscript is assigned; if additional time is required, the editor will follow up with the reviewer and/or assign a substitute reviewer to maintain the timeliness of the editorial process. Reviewers provide comments and recommendations regarding the suitability of the manuscript for publication and submit their comments and recommendations to the editor.</p>

<p>Based on the reviewers\' evaluations, the editor may issue one of the following decisions:</p>

<p>Minor Revision: Authors receive specific comments and are requested to revise the manuscript accordingly.<br>Major Revision: Authors are notified that the manuscript requires substantial revision and will undergo a second round of peer review after resubmission.<br>Decline Submission: Authors receive a formal rejection letter along with reviewer comments and are invited to resubmit as a new manuscript if substantial changes are made.</p>

<p>Once the revised manuscript is formally accepted by the Editor-in-Chief, the corresponding author will be issued a Letter of Acceptance (LOA). Jurnal Permukiman does not issue an LOA during the under-review, revision, or any other stage prior to the final acceptance decision.</p>

<p>The accepted manuscript then proceeds to the copyediting and layout stage, including verification of reference formatting and consistency. A final proofreading phase is conducted jointly by the editorial team and the author before the article is published.</p>

<p>Jurnal Permukiman maintains strict confidentiality throughout the review process. Author identities are removed before the manuscript is sent to reviewers to ensure impartiality. Final publication decisions are made by the Editor-in-Chief, taking into account the recommendations of reviewers and handling editors, to ensure a high standard of academic integrity and quality. The entire peer review process is carried out in accordance with the principles and guidelines of the <strong>Committee on Publication Ethics (COPE)</strong>, including confidentiality, objectivity, disclosure of conflicts of interest, and the transparent handling of allegations of publication misconduct.</p>

<p><img src="/public/site/images/lila/flowchart-publication-procedure--in-jurnal-permukiman--update-2-0c5c93807d66414d4262b65ef69f05c5.jpg" alt="" width="1587" height="2245"></p>';

    // Hapus setting lama untuk halaman ini jika ada
    $del = $pdo->prepare("DELETE FROM static_page_settings WHERE static_page_id = ?");
    $del->execute([$spId]);

    // Masukkan title dan content satu per satu dengan setting_type = 'string'
    $ins = $pdo->prepare("INSERT INTO static_page_settings (static_page_id, locale, setting_name, setting_value, setting_type) VALUES (?, ?, ?, ?, 'string')");
    $ins->execute([$spId, 'en_US', 'title', 'Peer Review Process']);
    $ins->execute([$spId, 'id_ID', 'title', 'Peer Review Process']);
    $ins->execute([$spId, 'en_US', 'content', $content]);
    $ins->execute([$spId, 'id_ID', 'content', $content]);

    $results['inserted_settings_for_spId'] = $spId;

    // 3. Update juga copyrightNotice (buang kata Transfer)
    $uCopy = $pdo->prepare("UPDATE journal_settings SET setting_value = REPLACE(setting_value, 'Download Copyright Transfer Agreement Form', 'Download Copyright and License Agreement') WHERE setting_name = 'copyrightNotice'");
    $uCopy->execute();
    $results['copyright_transfer_updated'] = $uCopy->rowCount();

    // 4. Bersihkan cache template OJS
    $files = glob('/var/www/html/cache/*.php') ?: [];
    $files = array_merge($files, glob('/var/www/html/cache/t_compile/*.php') ?: []);
    $files = array_merge($files, glob('/var/www/html/cache/t_cache/*.php') ?: []);
    $files = array_merge($files, glob('/var/www/html/cache/_db/*') ?: []);
    $cleared = 0;
    foreach ($files as $f) {
        if (is_file($f)) {
            @unlink($f);
            $cleared++;
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
