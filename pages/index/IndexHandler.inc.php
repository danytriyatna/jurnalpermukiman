<?php

/**
 * @file pages/index/IndexHandler.inc.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class IndexHandler
 * @ingroup pages_index
 *
 * @brief Handle site index requests.
 */

import('lib.pkp.pages.index.PKPIndexHandler');

class IndexHandler extends PKPIndexHandler {
	//
	// Public handler operations
	//
	/**
	 * If no journal is selected, display list of journals.
	 * Otherwise, display the index page for the selected journal.
	 * @param $args array
	 * @param $request Request
	 */
	function index($args, $request) {
		$this->validate(null, $request);
		$journal = $request->getJournal();

		if (!$journal) {
			$hasNoContexts = null; // Avoid scrutinizer warnings
			$journal = $this->getTargetContext($request, $hasNoContexts);
			if ($journal) {
				// There's a target context but no journal in the current request. Redirect.
				$request->redirect($journal->getPath());
			}
			if ($hasNoContexts && Validation::isSiteAdmin()) {
				// No contexts created, and this is the admin.
				$request->redirect(null, 'admin', 'contexts');
			}
		}

		$this->setupTemplate($request);
		$router = $request->getRouter();
		$templateMgr = TemplateManager::getManager($request);
		if ($journal) {
			// Assign header and content for home page
			$templateMgr->assign(array(
				'additionalHomeContent' => $journal->getLocalizedData('additionalHomeContent'),
				'homepageImage' => $journal->getLocalizedData('homepageImage'),
				'homepageImageAltText' => $journal->getLocalizedData('homepageImageAltText'),
				'journalDescription' => $journal->getLocalizedData('description'),
			));

			$issueDao = DAORegistry::getDAO('IssueDAO'); /* @var $issueDao IssueDAO */
			$issue = $issueDao->getCurrent($journal->getId(), true);
			if (isset($issue) && $journal->getData('publishingMode') != PUBLISHING_MODE_NONE) {
				import('pages.issue.IssueHandler');
				// The current issue TOC/cover page should be displayed below the custom home page.
				IssueHandler::_setupIssueTemplate($request, $issue);
			}

			$this->_setupAnnouncements($journal, $templateMgr);
			$this->_setupJournalInsights($journal, $templateMgr);

			$templateMgr->display('frontend/pages/indexJournal.tpl');
		} else {
			$journalDao = DAORegistry::getDAO('JournalDAO'); /* @var $journalDao JournalDAO */
			$site = $request->getSite();

			if ($site->getRedirect() && ($journal = $journalDao->getById($site->getRedirect())) != null) {
				$request->redirect($journal->getPath());
			}

			$templateMgr->assign([
				'pageTitleTranslated' => $site->getLocalizedTitle(),
				'about' => $site->getLocalizedAbout(),
				'journalFilesPath' => $request->getBaseUrl() . '/' . Config::getVar('files', 'public_files_dir') . '/journals/',
				'journals' => $journalDao->getAll(true)->toArray(),
				'site' => $site,
			]);
			$templateMgr->setCacheability(CACHEABILITY_PUBLIC);
			$templateMgr->display('frontend/pages/indexSite.tpl');
		}
	}

	/**
	 * Muat metrik ringkas editorial & dampak pembaca dari database OJS dengan
	 * cache berkas selama 1 jam agar halaman depan tetap ringan.
	 * @param $journal Journal
	 * @param $templateMgr PKPTemplateManager
	 */
	protected function _setupJournalInsights($journal, $templateMgr) {
		$journalId = (int) $journal->getId();
		$cacheManager = CacheManager::getManager();
		$cache = $cacheManager->getFileCache(
			'journalInsights',
			(string) $journalId,
			array($this, '_computeJournalInsightsFallback')
		);
		$cacheTime = $cache->getCacheTime();
		if ($cacheTime !== null && (time() - $cacheTime) > 3600) {
			$cache->flush();
		}

		$stats = $cache->get('stats');
		if (!is_array($stats)) {
			$stats = $this->_queryJournalInsights($journalId);
		}
		$templateMgr->assign('jpInsights', $stats);
	}

	/**
	 * Fallback FileCache saat cache metrik beranda belum ada atau kedaluwarsa.
	 * @param $cache FileCache
	 * @param $id string
	 * @return array
	 */
	public function _computeJournalInsightsFallback($cache, $id) {
		$stats = $this->_queryJournalInsights((int) $cache->getCacheId());
		$cache->setEntireCache(array('stats' => $stats));
		return $stats;
	}

	/**
	 * Hitung agregat publikasi, keputusan editorial, dan metrik pembaca OJS.
	 * @param $journalId int
	 * @return array
	 */
	protected function _queryJournalInsights($journalId) {
		import('lib.pkp.classes.submission.PKPSubmission');
		import('classes.workflow.EditorDecisionActionsManager');
		import('lib.pkp.classes.workflow.PKPEditorDecisionActionsManager');
		import('classes.statistics.StatisticsHelper');

		$metricsDao = DAORegistry::getDAO('MetricsDAO'); /* @var $metricsDao MetricsDAO */

		$subRes = $metricsDao->retrieve(
			'SELECT
				COUNT(*) AS total_submissions,
				COALESCE(SUM(CASE WHEN status = ? THEN 1 ELSE 0 END), 0) AS published_articles,
				COALESCE(SUM(CASE WHEN status = ? THEN 1 ELSE 0 END), 0) AS declined_submissions
			FROM submissions
			WHERE context_id = ? AND submission_progress = 0',
			array(STATUS_PUBLISHED, STATUS_DECLINED, $journalId)
		);
		$subRow = $subRes->current();
		$totalSubmissions = $subRow ? (int) $subRow->total_submissions : 0;
		$publishedArticles = $subRow ? (int) $subRow->published_articles : 0;
		$declinedStatusCount = $subRow ? (int) $subRow->declined_submissions : 0;

		$decRes = $metricsDao->retrieve(
			'SELECT
				COUNT(DISTINCT CASE WHEN ed.decision = ? AND s.status != ? THEN s.submission_id END) AS accepted_count,
				COUNT(DISTINCT CASE WHEN ed.decision IN (?, ?) AND s.status = ? THEN s.submission_id END) AS declined_count
			FROM submissions s
			INNER JOIN edit_decisions ed ON ed.submission_id = s.submission_id
			WHERE s.context_id = ? AND s.submission_progress = 0',
			array(
				SUBMISSION_EDITOR_DECISION_ACCEPT,
				STATUS_DECLINED,
				SUBMISSION_EDITOR_DECISION_DECLINE,
				SUBMISSION_EDITOR_DECISION_INITIAL_DECLINE,
				STATUS_DECLINED,
				$journalId,
			)
		);
		$decRow = $decRes->current();
		$acceptedCount = $decRow ? (int) $decRow->accepted_count : 0;
		$declinedCount = $decRow ? (int) $decRow->declined_count : 0;

		if ($acceptedCount === 0 && $declinedCount === 0) {
			$acceptedCount = $publishedArticles;
			$declinedCount = $declinedStatusCount;
		}
		$finalizedTotal = $acceptedCount + $declinedCount;
		$acceptanceRate = $finalizedTotal > 0 ? (int) round(($acceptedCount / $finalizedTotal) * 100) : 0;

		$metricRes = $metricsDao->retrieve(
			'SELECT
				COALESCE(SUM(CASE WHEN assoc_type = ? THEN metric ELSE 0 END), 0) AS abstract_views,
				COALESCE(SUM(CASE WHEN assoc_type = ? AND file_type = ? THEN metric ELSE 0 END), 0) AS pdf_downloads
			FROM metrics
			WHERE context_id = ?',
			array(
				ASSOC_TYPE_SUBMISSION,
				ASSOC_TYPE_SUBMISSION_FILE,
				STATISTICS_FILE_TYPE_PDF,
				$journalId,
			)
		);
		$metricRow = $metricRes->current();
		$abstractViews = $metricRow ? (int) $metricRow->abstract_views : 0;
		$pdfDownloads = $metricRow ? (int) $metricRow->pdf_downloads : 0;

		return array(
			'totalSubmissions' => $totalSubmissions,
			'totalSubmissionsFormatted' => number_format($totalSubmissions, 0, '.', ','),
			'publishedArticles' => $publishedArticles,
			'publishedArticlesFormatted' => number_format($publishedArticles, 0, '.', ','),
			'abstractViews' => $abstractViews,
			'abstractViewsFormatted' => number_format($abstractViews, 0, '.', ','),
			'pdfDownloads' => $pdfDownloads,
			'pdfDownloadsFormatted' => number_format($pdfDownloads, 0, '.', ','),
			'acceptedCount' => $acceptedCount,
			'acceptedCountFormatted' => number_format($acceptedCount, 0, '.', ','),
			'declinedCount' => $declinedCount,
			'declinedCountFormatted' => number_format($declinedCount, 0, '.', ','),
			'acceptanceRate' => $acceptanceRate,
		);
	}
}


