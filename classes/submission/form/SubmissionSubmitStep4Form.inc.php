<?php

/**
 * @file classes/submission/form/SubmissionSubmitStep4Form.inc.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class SubmissionSubmitStep4Form
 * @ingroup submission_form
 *
 * @brief Form for Step 4 of author submission.
 */

import('lib.pkp.classes.submission.form.PKPSubmissionSubmitStep4Form');

class SubmissionSubmitStep4Form extends PKPSubmissionSubmitStep4Form {
	/**
	 * Constructor.
	 * @param $context Context
	 * @param $submission Submission
	 */
	function __construct($context, $submission) {
		parent::__construct(
			$context,
			$submission
		);
	}

	/**
	 * Save changes to submission.
	 * @return int the submission ID
	 */
	function execute(...$functionParams) {
		parent::execute(...$functionParams);

		$submission = $this->submission;
		// Send author notification email
		import('classes.mail.ArticleMailTemplate');
		$request = Application::get()->getRequest();
		$context = $request->getContext();
		$router = $request->getRouter();
		$user = $request->getUser();

		$mail = new ArticleMailTemplate($submission, 'SUBMISSION_ACK', null, null, false);
		if ($mail->isEnabled()) {
			// submission ack emails should be from the contact.
			$mail->setFrom($this->context->getData('contactEmail'), $this->context->getData('contactName'));
			$mail->addRecipient($user->getEmail(), $user->getFullName());

			$mail->bccAssignedSubEditors($submission->getId(), WORKFLOW_STAGE_ID_SUBMISSION);

			$mail->assignParams([
				'authorName' => htmlspecialchars($user->getFullName()),
				'authorUsername' => htmlspecialchars($user->getUsername()),
				'editorialContactSignature' => htmlspecialchars($context->getData('contactName')),
				'submissionUrl' => $router->url($request, null, 'authorDashboard', 'submission', $submission->getId()),
			]);

			if (!$mail->send($request)) {
				import('classes.notification.NotificationManager');
				$notificationMgr = new NotificationManager();
				$notificationMgr->createTrivialNotification($request->getUser()->getId(), NOTIFICATION_TYPE_ERROR, array('contents' => __('email.compose.error')));
			}
		}

		$authorMail = new ArticleMailTemplate($submission, 'SUBMISSION_ACK_NOT_USER', null, null, false);
		if ($authorMail->isEnabled()) {
			$authorMail->setFrom($this->context->getData('contactEmail'), $this->context->getData('contactName'));

			$primaryAuthor = $submission->getPrimaryAuthor();
			if (!isset($primaryAuthor)) {
				$authors = $submission->getAuthors();
				$primaryAuthor = $authors[0];
			}

			if ($user->getEmail() != $primaryAuthor->getEmail()) {
				$authorMail->addRecipient($primaryAuthor->getEmail(), $primaryAuthor->getFullName());
			}

			$assignedAuthors = $submission->getAuthors();
			foreach ($assignedAuthors as $author) {
				$authorEmail = $author->getEmail();
				// only add the author email if they have not already been added as the primary author
				// or user creating the submission.
				if ($authorEmail != $primaryAuthor->getEmail() && $authorEmail != $user->getEmail()) {
					$authorMail->addRecipient($author->getEmail(), $author->getFullName());
				}
			}

			$authorMail->assignParams([
				'submitterName' => htmlspecialchars($user->getFullName()),
				'editorialContactSignature' => htmlspecialchars($context->getData('contactName')),
			]);

			if (!empty($authorMail->getRecipients()) && !$authorMail->send($request)) {
				import('classes.notification.NotificationManager');
				$notificationMgr = new NotificationManager();
				$notificationMgr->createTrivialNotification($request->getUser()->getId(), NOTIFICATION_TYPE_ERROR, array('contents' => __('email.compose.error')));
			}
		}

		// Log submission.
		import('classes.log.SubmissionEventLogEntry'); // Constants
		import('lib.pkp.classes.log.SubmissionLog');
		SubmissionLog::logEvent($request, $submission, SUBMISSION_LOG_SUBMISSION_SUBMIT, 'submission.event.submissionSubmitted');

		// Sinkronisasi otomatis ke MQC Assistant saat naskah selesai diserahkan (Tahap Konfirmasi)
		$this->_syncManuscriptToMQC($submission);

		return $this->submissionId;
	}

	/**
	 * Transmisikan berkas naskah utama (.docx) dan metadata lengkap ke MQC Assistant
	 * secara non-blocking / safe-fail agar tidak mengganggu alur submission OJS.
	 *
	 * @param Submission $submission
	 */
	protected function _syncManuscriptToMQC($submission) {
		try {
			if (!$submission) {
				return;
			}

			$submissionId = $submission->getId();
			$publication = $submission->getCurrentPublication();
			$title = $publication ? $publication->getLocalizedTitle() : $submission->getLocalizedTitle();

			// Cari nama dan email penulis (utamakan primary author, fallback ke session user)
			$authorName = '';
			$authorEmail = '';
			$primaryAuthor = $submission->getPrimaryAuthor();
			if (!$primaryAuthor) {
				$authors = $submission->getAuthors();
				if (!empty($authors)) {
					$primaryAuthor = $authors[0];
				}
			}

			if ($primaryAuthor) {
				$authorName = $primaryAuthor->getFullName();
				$authorEmail = $primaryAuthor->getEmail();
			} else {
				$request = Application::get()->getRequest();
				$user = $request ? $request->getUser() : null;
				if ($user) {
					$authorName = $user->getFullName();
					$authorEmail = $user->getEmail();
				}
			}

			$request = Application::get()->getRequest();
			$user = $request ? $request->getUser() : null;
			$userId = $user ? $user->getId() : null;

			// Cari berkas naskah utama (.docx) di SUBMISSION_FILE_SUBMISSION
			$filesService = Services::get('submissionFile');
			$files = $filesService->getMany([
				'submissionIds' => [$submissionId],
				'fileStages' => [SUBMISSION_FILE_SUBMISSION],
			]);

			$filePath = null;
			$fileName = 'manuscript.docx';
			$filesDir = rtrim(Config::getVar('files', 'files_dir'), '/\\');

			foreach ($files as $file) {
				$genreId = (int) $file->getData('genreId');
				$relPath = $file->getData('path');
				$fullPath = $filesDir . '/' . ltrim($relPath, '/\\');
				if (file_exists($fullPath)) {
					$origName = $file->getLocalizedData('name') ?: basename($fullPath);
					// Jangan pernah mengirim balik berkas laporan hasil pemeriksaan MQC (genreId 14 / prefix Laporan-review-)
					if (
						$genreId === 14 ||
						stripos($origName, 'Laporan-review-') === 0 ||
						stripos($origName, 'Laporan-MQC-') === 0
					) {
						continue;
					}
					if (strtolower(pathinfo($origName, PATHINFO_EXTENSION)) === 'docx') {
						$filePath = $fullPath;
						$fileName = $origName;
						break;
					}
					if (!$filePath) {
						$filePath = $fullPath;
						$fileName = $origName;
					}
				}
			}

			if (!$filePath || !file_exists($filePath)) {
				error_log("[MQC Sync Warning] Berkas naskah untuk submission #{$submissionId} tidak ditemukan di files_dir.");
				return;
			}

			$mqcUrl = Config::getVar('mqc', 'api_url') ?: 'http://localhost:3000/api/check-submission';
			$mqcKey = trim((string) Config::getVar('mqc', 'api_key'));
			if ($mqcKey === '') {
				error_log("[MQC Sync Warning] Konfigurasi [mqc] api_key kosong di config.inc.php.");
				return;
			}

			$postFields = [
				'file' => new \CURLFile($filePath, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', $fileName),
				'ojs_submission_id' => (string) $submissionId,
				'ojs_user_id' => $userId ? (string) $userId : '',
				'author_name' => $authorName ?: 'Penulis Jurnal Permukiman',
				'author_email' => $authorEmail ?: '',
				'title' => $title ?: "Naskah OJS #{$submissionId}",
			];

			$ch = curl_init($mqcUrl);
			curl_setopt_array($ch, [
				CURLOPT_POST => true,
				CURLOPT_POSTFIELDS => $postFields,
				CURLOPT_HTTPHEADER => [
					'x-mqc-api-key: ' . $mqcKey,
				],
				CURLOPT_RETURNTRANSFER => true,
				CURLOPT_CONNECTTIMEOUT => 1,
				CURLOPT_TIMEOUT => 2,
			]);

			$response = curl_exec($ch);
			$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
			$curlErr = curl_error($ch);
			curl_close($ch);

			if ($httpCode === 200) {
				error_log("[MQC Sync Success] Naskah OJS #{$submissionId} ('{$title}') berhasil disinkronkan ke MQC.");
			} else {
				error_log("[MQC Sync Warning] HTTP {$httpCode} dari MQC: " . ($response ?: $curlErr));
			}
		} catch (\Throwable $e) {
			error_log("[MQC Sync Error] Gagal menyinkronkan naskah OJS ke MQC: " . $e->getMessage());
		}

		return $this->submissionId;
	}
}


