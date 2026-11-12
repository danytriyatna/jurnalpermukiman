<?php

/**
 * @file controllers/grid/users/queries/form/QueryNoteForm.inc.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class QueryNoteForm
 * @ingroup controllers_grid_users_queries_form
 *
 * @brief Form for adding/editing a new query note.
 */

import('lib.pkp.classes.form.Form');

class QueryNoteForm extends Form {
	/** @var array Action arguments */
	var $_actionArgs;

	/** @var Query */
	var $_query;

	/** @var int Note ID */
	var $_noteId;

	/** @var boolean Whether or not this is a new note */
	var $_isNew;

	/**
	 * Constructor.
	 * @param $actionArgs array Action arguments
	 * @param $query Query
	 * @param $user User The current user ID
	 * @param $noteId int The note ID to edit, or null for new.
	 */
	function __construct($actionArgs, $query, $user, $noteId = null) {
		parent::__construct('controllers/grid/queries/form/queryNoteForm.tpl');
		$this->_actionArgs = $actionArgs;
		$this->setQuery($query);

		if ($noteId === null) {
			// Create a new (placeholder) note.
			$noteDao = DAORegistry::getDAO('NoteDAO'); /* @var $noteDao NoteDAO */
			$note = $noteDao->newDataObject();
			$note->setAssocType(ASSOC_TYPE_QUERY);
			$note->setAssocId($query->getId());
			$note->setUserId($user->getId());
			$note->setDateCreated(Core::getCurrentDate());
			$this->_noteId = $noteDao->insertObject($note);
			$this->_isNew = true;
		} else {
			$this->_noteId = $noteId;
			$this->_isNew = false;
		}

		// Validation checks for this form
		$this->addCheck(new FormValidator($this, 'comment', 'required', 'submission.queries.messageRequired'));
		$this->addCheck(new FormValidatorPost($this));
		$this->addCheck(new FormValidatorCSRF($this));
	}

	//
	// Getters and Setters
	//
	/**
	 * Get the query
	 * @return Query
	 */
	function getQuery() {
		return $this->_query;
	}

	/**
	 * Set the query
	 * @param @query Query
	 */
	function setQuery($query) {
		$this->_query = $query;
	}

	/**
	 * Assign form data to user-submitted data.
	 * @see Form::readInputData()
	 */
	function readInputData() {
		$this->readUserVars(array(
			'comment',
		));
	}

	/**
	 * @copydoc Form::fetch
	 */
	function fetch($request, $template = null, $display = false) {
		$templateMgr = TemplateManager::getManager($request);
		$templateMgr->assign(array(
			'actionArgs' => $this->_actionArgs,
			'noteId' => $this->_noteId,
			'csrfToken' => $request->getSession()->getCSRFToken(),
		));
		return parent::fetch($request, $template, $display);
	}

	/**
	 * @copydoc Form::execute()
	 * @return Note The created note object.
	 */
	function execute(...$functionArgs) {
		$request = Application::get()->getRequest();
		$user = $request->getUser();

		// Create a new note.
		$noteDao = DAORegistry::getDAO('NoteDAO'); /* @var $noteDao NoteDAO */
		$note = $noteDao->getById($this->_noteId);
		$note->setUserId($request->getUser()->getId());
		$note->setContents($this->getData('comment'));
		$noteDao->updateObject($note);

		// Check whether the query needs re-opening
		$query = $this->getQuery();
		if ($query->getIsClosed()) {
			$headNote = $query->getHeadNote();
			if ($user->getId() != $headNote->getUserId()) {
				// Re-open the query.
				$query->setIsClosed(false);
				$queryDao = DAORegistry::getDAO('QueryDAO'); /* @var $queryDao QueryDAO */
				$queryDao->updateObject($query);
			}
		}

		$notificationDao = DAORegistry::getDAO('NotificationDAO'); /* @var $notificationDao NotificationDAO */
		$queryDao = DAORegistry::getDAO('QueryDAO'); /* @var $queryDao QueryDAO */

		// Always include current user to query participants
		if (!in_array($user->getId(), $queryDao->getParticipantIds($query->getId()))) {
			$queryDao->insertParticipant($query->getId(), $user->getId());
		}

		$notificationManager = new NotificationManager();
		foreach ($queryDao->getParticipantIds($query->getId()) as $userId) {
			// Delete any prior notifications of the same type (e.g. prior "new" comments)
			$notificationDao->deleteByAssoc(
				ASSOC_TYPE_QUERY, $query->getId(),
				$userId, NOTIFICATION_TYPE_QUERY_ACTIVITY,
				$request->getContext()->getId()
			);

			// No need to additionally notify the posting user.
			if ($userId == $user->getId()) continue;

			// Notify the user of a new query.
			$notificationManager->createNotification(
				$request,
				$userId,
				NOTIFICATION_TYPE_QUERY_ACTIVITY,
				$request->getContext()->getId(),
				ASSOC_TYPE_QUERY,
				$query->getId(),
				NOTIFICATION_LEVEL_TASK
			);
		}

		parent::execute(...$functionArgs);

		// Synchronize attached revision manuscript (.docx) to MQC if present
		$this->_syncRevisionToMqc($request, $note);

		return $note;
	}

	/**
	 * Synchronize revision manuscript (.docx) to MQC if attached in this note.
	 * Filters strictly by Article Component (genreId 1 = Naskah / Article Text or 15 = Revised Manuscript).
	 *
	 * @param PKPRequest $request
	 * @param Note $note
	 */
	protected function _syncRevisionToMqc($request, $note) {
		try {
			$query = $this->getQuery();
			if (!$query) return;

			// Pastikan query terikat ke naskah (ASSOC_TYPE_SUBMISSION = 1048585)
			if ($query->getAssocType() != ASSOC_TYPE_SUBMISSION) return;

			$submissionId = (int) $query->getAssocId();
			if (!$submissionId) return;

			// Periksa apakah konfigurasi MQC ada di config.inc.php
			$mqcUrl = Config::getVar('mqc', 'api_url') ?: 'http://localhost:3000/api/check-submission';
			$mqcKey = trim((string) Config::getVar('mqc', 'api_key'));
			if ($mqcKey === '') {
				return;
			}

			// Ambil berkas lampiran yang terikat pada note ini
			import('classes.core.Services');
			import('lib.pkp.classes.submission.SubmissionFile');
			$filesService = Services::get('submissionFile');
			$files = $filesService->getMany([
				'assocTypes' => [ASSOC_TYPE_NOTE],
				'assocIds' => [(int) $note->getId()],
				'submissionIds' => [$submissionId],
				'fileStages' => [SUBMISSION_FILE_QUERY],
			]);

			$filesDir = rtrim(Config::getVar('files', 'files_dir'), '/\\');
			$targetFile = null;
			$targetFullPath = null;
			$targetOrigName = null;

			foreach ($files as $file) {
				$genreId = (int) $file->getData('genreId');

				// Filter ketat Article Component: HANYA genre_id = 1 (Article Text/Naskah) atau 15 (Revised Manuscript)
				if ($genreId !== 1 && $genreId !== 15) {
					continue;
				}

				// Abaikan jika berkas laporan review MQC
				$origName = $file->getLocalizedData('name') ?: basename($file->getData('path'));
				if (
					$genreId === 14 ||
					stripos($origName, 'Laporan-review-') === 0 ||
					stripos($origName, 'Laporan-MQC-') === 0
				) {
					continue;
				}

				// Wajib berekstensi .docx
				if (strtolower(pathinfo($origName, PATHINFO_EXTENSION)) !== 'docx') {
					continue;
				}

				$relPath = $file->getData('path');
				$fullPath = $filesDir . '/' . ltrim($relPath, '/\\');
				if (file_exists($fullPath)) {
					$targetFile = $file;
					$targetFullPath = $fullPath;
					$targetOrigName = $origName;
					break;
				}
			}

			if (!$targetFile || !$targetFullPath) {
				// Tidak ada berkas naskah revisi (.docx) yang memenuhi syarat di catatan ini
				return;
			}

			// Ambil metadata naskah & penulis
			$submission = Services::get('submission')->get($submissionId);
			$title = $submission ? $submission->getLocalizedTitle() : "Naskah OJS #{$submissionId}";
			$author = $submission ? $submission->getPrimaryAuthor() : null;
			$user = $request ? $request->getUser() : null;
			$userId = $user ? $user->getId() : null;
			$authorName = $author ? $author->getFullName() : ($user ? $user->getFullName() : 'Penulis Jurnal Permukiman');
			$authorEmail = $author ? $author->getEmail() : ($user ? $user->getEmail() : '');

			$postFields = [
				'file' => new \CURLFile($targetFullPath, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', $targetOrigName),
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
				CURLOPT_TIMEOUT => 3,
			]);

			$response = curl_exec($ch);
			$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
			$curlErr = curl_error($ch);
			curl_close($ch);

			if ($httpCode === 200) {
				error_log("[MQC Revision Sync Success] Naskah revisi OJS #{$submissionId} ('{$targetOrigName}', genreId: {$targetFile->getData('genreId')}) berhasil disinkronkan ke MQC dari diskusi note #{$note->getId()}.");
			} else {
				error_log("[MQC Revision Sync Warning] HTTP {$httpCode} dari MQC: " . ($response ?: $curlErr));
			}
		} catch (\Throwable $e) {
			error_log("[MQC Revision Sync Error] Gagal menyinkronkan revisi OJS ke MQC: " . $e->getMessage());
		}
	}
}


