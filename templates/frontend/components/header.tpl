{**
 * templates/frontend/components/header.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Common frontend site header aligned with Claude Artifact Design:
 *        1. Full-Width Edge-to-Edge Hero Card with KemenPU identity & deep rust scrim.
 *        2. Full-Width Horizontal 4-Card Quick Statistics section across page.
 *}
{strip}
	{assign var="showingLogo" value=true}
	{if !$displayPageHeaderLogo}
		{assign var="showingLogo" value=false}
	{/if}
{/strip}
<!DOCTYPE html>
<html lang="{$currentLocale|replace:"_":"-"}" xml:lang="{$currentLocale|replace:"_":"-"}">
{if !$pageTitleTranslated}{capture assign="pageTitleTranslated"}{translate key=$pageTitle}{/capture}{/if}
{include file="frontend/components/headerHead.tpl"}
<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"}{if $showingLogo} has_site_logo{/if}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

	{* FULL-WIDTH HERO HEADER SECTION (EDGE-TO-EDGE) *}
	<header class="pkp_structure_head hero_card_fullwidth" id="headerNavigationContainer" role="banner">
		{* Skip to content nav links *}
		{include file="frontend/components/skipLinks.tpl"}

		{capture assign="homeUrl"}{url page="index" router=$smarty.const.ROUTE_PAGE}{/capture}

		{* Top Nav Bar (Container 1280px) *}
		<nav class="jp_art_navbar" aria-label="{translate|escape key="common.navigation.site"}">
			<div class="jp_art_nav_container">
				<a href="{$homeUrl}" class="jp_art_brand">
					<span class="jp_art_logo_pill">
						<img src="{$baseUrl}/public/journals/1/kemenpu_pill_clean.png" alt="Kementerian Pekerjaan Umum" class="jp_art_logo_img" onerror="this.onerror=null;this.src='{$baseUrl}/public/journals/1/logo-pu-badge.png';">
					</span>
					<span class="jp_art_brand_text">
						<span class="jp_art_brand_title">JURNAL PERMUKIMAN</span>
						<span class="jp_art_brand_sub">e-ISSN 2339-2975 &middot; Ministry of Public Works</span>
					</span>
				</a>

				<div class="jp_art_nav_links">
					<a href="{$homeUrl}" class="{if !$requestedPage || $requestedPage === 'index'}is_active{/if}">Home</a>
					<a href="{url page="about" router=$smarty.const.ROUTE_PAGE}">About <i class="fa fa-caret-down" aria-hidden="true" style="font-size:11px;"></i></a>
					<a href="{url page="issue" op="current" router=$smarty.const.ROUTE_PAGE}">Current</a>
					<a href="{url page="issue" op="archive" router=$smarty.const.ROUTE_PAGE}">Archives</a>
					<a href="{url page="announcement" router=$smarty.const.ROUTE_PAGE}">Announcements</a>
					{if $isUserLoggedIn}
						<a href="{url page="submissions" router=$smarty.const.ROUTE_PAGE}" class="jp_user_chip">
							<i class="fa fa-user"></i> {$currentUser->getUsername()|escape}
						</a>
						<a href="{url page="login" op="signOut" router=$smarty.const.ROUTE_PAGE}" title="Logout"><i class="fa fa-sign-out"></i></a>
					{else}
						<a href="{url page="login" router=$smarty.const.ROUTE_PAGE}">Login</a>
						<a href="{url page="user" op="register" router=$smarty.const.ROUTE_PAGE}" class="jp_nav_register_pill">Register</a>
					{/if}
					<a href="{url page="search" router=$smarty.const.ROUTE_PAGE}" aria-label="Search" class="jp_nav_search_btn">
						<i class="fa fa-search" aria-hidden="true"></i>
					</a>

					{* Quick Access Ecosystem Buttons: MQC & JP *}
					<div class="jp_ecosystem_capsules">
						<a href="http://{$smarty.server.SERVER_NAME|default:'localhost'}:3000" target="_blank" rel="noopener noreferrer" class="jp_capsule_btn mqc" title="Akses MQC Assistant">MQC &nearr;</a>
						<a href="http://{$smarty.server.SERVER_NAME|default:'localhost'}:3001" target="_blank" rel="noopener noreferrer" class="jp_capsule_btn jp" title="Akses JP-Insight">JP &nearr;</a>
					</div>
				</div>
			</div>
		</nav>

		{* Hero Banner Headline Content (Container 1280px) *}
		<div class="jp_art_hero_body">
			<div class="jp_art_hero_lead">
				<div class="jp_art_hero_badges">
					<span class="jp_hero_badge oa">
						<span class="jp_badge_gold_dot"></span> Open Access Journal
					</span>
					<span class="jp_hero_badge">Double-blind Peer Review</span>
					<a href="https://sinta.kemdikbud.go.id/journals/profile/2822" target="_blank" rel="noopener" class="jp_hero_badge sinta">
						<i class="fa fa-certificate text-gold" style="color: #F5B335;"></i> SINTA Accredited
					</a>
				</div>
				<h1 class="jp_art_hero_title">Jurnal Permukiman</h1>
				<p class="jp_art_hero_desc">
					A peer-reviewed, open access scholarly journal that publishes original research, reviews, and conceptual papers in the field of human settlements, covering urban and rural areas, the buildings within them, and the facilities and infrastructure that support community life and livelihoods. Published by the Directorate of Building and Environmental Sanitation Engineering Development, Directorate General of Human Settlements, Ministry of Public Works, Indonesia.
				</p>
				<div class="jp_art_hero_actions">
					<a href="{url router=$smarty.const.ROUTE_PAGE page="about" op="submissions"}" class="jp_hero_btn_primary">
						<i class="fa fa-upload" aria-hidden="true"></i>
						<span>Submit Manuscript</span>
					</a>
					<a href="{url router=$smarty.const.ROUTE_PAGE page="about" op="submissions"}#authorGuidelines" class="jp_hero_btn_secondary">
						<span>Author Guidelines</span>
					</a>
				</div>
			</div>
			<div class="jp_art_hero_caption">
				<span class="jp_caption_pill">
					Kantor Direktorat Bina Teknik Bangunan Gedung dan Penyehatan Lingkungan
				</span>
			</div>
		</div>
	</header><!-- .hero_card_fullwidth -->

	{* TOP 4 STATISTIC CARDS (1 ROW 4 COLUMNS FULL WIDTH HORIZONTAL) *}
	{if !$requestedPage || $requestedPage === 'index'}
		<section class="jp_art_stat_cards_fullwidth" aria-label="Journal Statistics Overview">
			<div class="jp_art_stat_container">
				<div class="jp_art_stat_grid">
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box doc">
							<i class="fa fa-file-text-o" aria-hidden="true"></i>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">228</div>
							<div class="jp_stat_title">Published Articles</div>
						</div>
					</div>
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box user">
							<i class="fa fa-users" aria-hidden="true"></i>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">387</div>
							<div class="jp_stat_title">Registered Authors</div>
						</div>
					</div>
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box issue">
							<i class="fa fa-book" aria-hidden="true"></i>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">37</div>
							<div class="jp_stat_title">Issues Published</div>
						</div>
					</div>
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box download">
							<i class="fa fa-download" aria-hidden="true"></i>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">642K+</div>
							<div class="jp_stat_title">PDF Downloads</div>
						</div>
					</div>
				</div>
			</div>
		</section>
	{/if}

	{* MAIN PAGE CONTENT WRAPPER (1280PX CENTERED) *}
	<div class="pkp_structure_page">

		{* Wrapper for page content and sidebars *}
		{if $isFullWidth}
			{assign var=hasSidebar value=0}
		{/if}
		<div class="pkp_structure_content{if $hasSidebar} has_sidebar{/if}">
			<div class="pkp_structure_main" role="main">
				<a id="pkp_content_main"></a>
