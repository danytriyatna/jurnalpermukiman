<?php

/**
 * @file controllers/grid/files/submission/AuthorSubmissionDetailsFilesGridHandler.inc.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2000-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class AuthorSubmissionDetailsFilesGridHandler
 * @ingroup controllers_grid_files_submission
 *
 * @brief Handle submission file grid requests on the author's submission details pages.
 */

// Import the grid layout.
import('lib.pkp.controllers.grid.files.fileList.FileListGridHandler');
import('lib.pkp.controllers.grid.files.SubmissionFilesGridRow');

class AuthorSubmissionDetailsFilesGridHandler extends FileListGridHandler {
	/**
	 * Constructor
	 */
	function __construct() {
		import('lib.pkp.controllers.grid.files.SubmissionFilesGridDataProvider');
		$dataProvider = new SubmissionFilesGridDataProvider(SUBMISSION_FILE_SUBMISSION);
		parent::__construct($dataProvider, WORKFLOW_STAGE_ID_SUBMISSION, FILE_GRID_DOWNLOAD_ALL|FILE_GRID_EDIT);

		$this->addRoleAssignment(
			array(ROLE_ID_MANAGER, ROLE_ID_SUB_EDITOR, ROLE_ID_ASSISTANT, ROLE_ID_AUTHOR),
			array('fetchGrid', 'fetchRow')
		);

		// Grid title.
		$this->setTitle('submission.submit.submissionFiles');
	}

	/**
	 * @copydoc GridHandler::getRowInstance()
	 */
	protected function getRowInstance() {
		$userRoles = (array) $this->getAuthorizedContextObject(ASSOC_TYPE_USER_ROLES);
		return new AuthorSubmissionDetailsFilesGridRow($this->getCapabilities(), $this->getStageId(), $userRoles);
	}
}

class AuthorSubmissionDetailsFilesGridRow extends SubmissionFilesGridRow {
	/** @var array */
	var $_userRoles;

	function __construct($capabilities = null, $stageId = null, $userRoles = array()) {
		$this->_userRoles = $userRoles;
		parent::__construct($capabilities, $stageId);
	}

	/**
	 * @copydoc GridRow::initialize()
	 */
	function initialize($request, $template = 'controllers/grid/gridRow.tpl') {
		parent::initialize($request, $template);

		// Author is only authorized to modify files that were uploaded by themselves.
		// If the file was uploaded by another user (e.g. mqc_service / editorial team),
		// remove the 'editFile' link action so author does not see a non-functional Edit button.
		$submissionFileData =& $this->getData();
		if (isset($submissionFileData['submissionFile'])) {
			$submissionFile =& $submissionFileData['submissionFile'];
			$user = $request->getUser();
			if ($user && is_a($submissionFile, 'SubmissionFile')) {
				$isManagerOrEditor = in_array(ROLE_ID_MANAGER, $this->_userRoles) || in_array(ROLE_ID_SUB_EDITOR, $this->_userRoles);
				// If not editor/manager and user is not the uploader, remove the 'editFile' action
				if (!$isManagerOrEditor && $submissionFile->getUploaderUserId() != $user->getId()) {
					unset($this->_actions[GRID_ACTION_POSITION_DEFAULT]['editFile']);
				}
			}
		}
	}
}


