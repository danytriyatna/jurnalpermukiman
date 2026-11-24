<?php

/**
 * @file plugins/generic/customBlockManager/CustomBlockPlugin.inc.php
 *
 * Copyright (c) 2014-2020 Simon Fraser University
 * Copyright (c) 2003-2020 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @package plugins.generic.customBlockManager
 * @class CustomBlockPlugin
 *
 * A generic sidebar block that can be customized through the CustomBlockManagerPlugin
 *
 */

import('lib.pkp.classes.plugins.BlockPlugin');

class CustomBlockPlugin extends BlockPlugin {
	/** @var string Name of this block plugin */
	var $_blockName;

	/** @var CustomBlockManagerPlugin Parent plugin */
	var $_parentPlugin;

	/**
	 * Constructor
	 * @param $blockName string Name of this block plugin.
	 * @param $parentPlugin CustomBlockManagerPlugin Custom block plugin management plugin.
	 */
	function __construct($blockName, $parentPlugin) {
		$this->_blockName = $blockName;
		$this->_parentPlugin = $parentPlugin;
		parent::__construct();
	}

	/**
	 * Get the management plugin
	 * @return CustomBlockManagerPlugin
	 */
	function getManagerPlugin() {
		return $this->_parentPlugin;
	}

	/**
	 * @copydoc Plugin::getName()
	 */
	function getName() {
		return $this->_blockName;
	}

	/**
	 * @copydoc Plugin::getPluginPath()
	 */
	function getPluginPath() {
		$plugin = $this->getManagerPlugin();
		return $plugin->getPluginPath();
	}

	/**
	 * @copydoc Plugin::getTemplatePath()
	 */
	function getTemplatePath($inCore = false) {
		$plugin = $this->getManagerPlugin();
		return $plugin->getTemplatePath($inCore);
	}

	/**
	 * @copydoc Plugin::getHideManagement()
	 */
	function getHideManagement() {
		return true;
	}

	/**
	 * @copydoc LazyLoadPlugin::getEnabled()
	 */
	function getEnabled($contextId = null) {
		if (!Config::getVar('general', 'installed')) return true;
		return parent::getEnabled($contextId);
	}

	/**
	 * @copydoc Plugin::getDisplayName()
	 */
	function getDisplayName() {
		return $this->_blockName . ' ' . __('plugins.generic.customBlock.nameSuffix');
	}

	/**
	 * @copydoc Plugin::getDescription()
	 */
	function getDescription() {
		return __('plugins.generic.customBlock.description');
	}

	/**
	 * @copydoc BlockPlugin::getContents()
	 */
	function getContents($templateMgr, $request = null) {
		$context = $request->getContext();
		$contextId = $context ? $context->getId() : 0;

		// Get the block contents.
		$customBlockTitle = $this->getSetting($contextId, 'blockTitle');
		$customBlockContent = $this->getSetting($contextId, 'blockContent');
		$currentLocale = AppLocale::getLocale();
		$contextPrimaryLocale = $context?$context->getPrimaryLocale():$request->getSite()->getPrimaryLocale();

		$divCustomBlockId = 'customblock-'.preg_replace('/\W+/', '-', $this->getName());
		$templateMgr->assign('customBlockId', $divCustomBlockId);

		$title = $customBlockTitle[$currentLocale] ? $customBlockTitle[$currentLocale] : $customBlockTitle[$contextPrimaryLocale];
		$content = $customBlockContent[$currentLocale] ? $customBlockContent[$currentLocale] : $customBlockContent[$contextPrimaryLocale];

		// Dynamic URL normalization: replace hardcoded production URLs with current context URL and local /public path
		if ($content) {
			if ($context) {
				$journalUrl = $request->url($context->getPath());
				$content = str_ireplace(
					array(
						'https://jurnalpermukiman.pu.go.id/index.php/JP',
						'http://jurnalpermukiman.pu.go.id/index.php/JP',
					),
					$journalUrl,
					$content
				);
			}
			$basePath = $request ? rtrim($request->getBasePath(), '/') : '';
			$publicUrl = $basePath . '/public/';
			$content = str_ireplace(
				array(
					'https://jurnalpermukiman.pu.go.id/public/',
					'http://jurnalpermukiman.pu.go.id/public/',
					'//jurnalpermukiman.pu.go.id/public/',
				),
				$publicUrl,
				$content
			);

			// Automatically rewrite external flagcounter to local proxy to prevent adblocker blocks
			if (stripos($content, 'flagcounter') !== false) {
				$counterUrl = $basePath . '/visitor-counter.php';
				$content = preg_replace(
					'/https?:\/\/[a-z0-9\.]*flagcounter\.com\/count[0-9]*\/[^\s"\'<>]+/i',
					$counterUrl,
					$content
				);
				$content = preg_replace(
					'/https?:\/\/[a-z0-9\.]*flagcounter\.com\/today\/[^\s"\'<>]+/i',
					'https://statcounter.com/p12885777/?guest=1',
					$content
				);
			}

			// Clean up data-kunjungan: strip invisible tracking pixel paragraph and leading &nbsp;
			if (stripos($content, 'c.statcounter.com/12885777') !== false || stripos($content, 'stat.png') !== false) {
				$content = preg_replace('/<p>\s*<a[^>]*title=["\']web statistics["\'][^>]*>.*?<\/a>\s*<\/p>/is', '', $content);
				$content = preg_replace('/<p>\s*&nbsp;/i', '<p>', $content);
			}

			// Mark active item exclusively in JOURNAL POLICY sidebar without altering other blocks
			if ($divCustomBlockId === 'customblock-journal-police') {
				$content = $this->_markActivePolicyLinks($content, $request);
			}
		}

		$templateMgr->assign('customBlockTitle', $title);
		$templateMgr->assign('customBlockContent', $content);
		$templateMgr->assign('showName', $this->getSetting($contextId, 'showName'));


		// Validasi: jika tidak ada data/konten yang ditampilkan, jangan tampilkan judul maupun blok
		if (trim(strip_tags($content, '<img><iframe><svg><object><embed><video><audio>')) === '') {
			return '';
		}

		return parent::getContents($templateMgr, $request);

	}

	/**
	 * Add active row class and aria-current="page" to matching links in JOURNAL POLICY.
	 *
	 * @param string $content
	 * @param PKPRequest|null $request
	 * @return string
	 */
	function _markActivePolicyLinks($content, $request) {
		if (!$content || !$request) {
			return $content;
		}

		$currentParts = @parse_url($request->getRequestUrl());
		if (empty($currentParts['path'])) {
			return $content;
		}
		$currentPath = strtolower(rtrim($currentParts['path'], '/'));
		$currentHost = isset($currentParts['host']) ? strtolower($currentParts['host']) : '';

		// Process per paragraph/list-item block so raw TinyMCE HTML & UTF-8 stay intact
		return preg_replace_callback(
			'/<(p|li)(\b[^>]*)>(.*?)<\/\1>/is',
			function ($rowMatch) use ($currentPath, $currentHost) {
				$tagName = $rowMatch[1];
				$tagAttrs = $rowMatch[2];
				$rowBody = $rowMatch[3];
				$isRowActive = false;

				$rowBody = preg_replace_callback(
					'/<a\b([^>]*)href=(["\'])([^"\']*)\2([^>]*)>/is',
					function ($linkMatch) use ($currentPath, $currentHost, &$isRowActive) {
						$href = html_entity_decode(trim($linkMatch[3]), ENT_QUOTES, 'UTF-8');
						if ($href === '' || $href[0] === '#') {
							return $linkMatch[0];
						}

						$hrefParts = @parse_url($href);
						if (empty($hrefParts['path'])) {
							return $linkMatch[0];
						}
						if (!empty($hrefParts['host']) && $currentHost !== '' && strtolower($hrefParts['host']) !== $currentHost) {
							return $linkMatch[0];
						}

						$hrefPath = strtolower(rtrim($hrefParts['path'], '/'));
						if ($hrefPath !== $currentPath) {
							return $linkMatch[0];
						}

						$isRowActive = true;
						$attrs = $linkMatch[1] . 'href=' . $linkMatch[2] . $linkMatch[3] . $linkMatch[2] . $linkMatch[4];
						if (stripos($attrs, 'aria-current') === false) {
							$attrs .= ' aria-current="page"';
						}
						return '<a' . $attrs . '>';
					},
					$rowBody
				);

				if ($isRowActive) {
					$tagAttrs = $this->_appendCssClass($tagAttrs, 'jp-policy-active');
				}
				return '<' . $tagName . $tagAttrs . '>' . $rowBody . '</' . $tagName . '>';
			},
			$content
		);
	}

	/**
	 * Append a CSS class token to tag attributes without duplicating existing classes.
	 *
	 * @param string $tagAttrs
	 * @param string $className
	 * @return string
	 */
	function _appendCssClass($tagAttrs, $className) {
		if (preg_match('/\bclass=(["\'])([^"\']*)\1/i', $tagAttrs, $m)) {
			$classes = preg_split('/\s+/', trim($m[2]));
			if (in_array($className, $classes, true)) {
				return $tagAttrs;
			}
			$updated = trim($m[2] . ' ' . $className);
			return preg_replace(
				'/\bclass=(["\'])([^"\']*)\1/i',
				'class=' . $m[1] . $updated . $m[1],
				$tagAttrs,
				1
			);
		}
		return $tagAttrs . ' class="' . $className . '"';
	}
}

