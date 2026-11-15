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
	<header class="pkp_structure_head hero_card_fullwidth{if $requestedPage && $requestedPage !== 'index'} jp_subpage_header{/if}" id="headerNavigationContainer" role="banner">
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
				</div>
			</div>
		</nav>

		{if !$requestedPage || $requestedPage === 'index'}
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
			</div><!-- .jp_art_hero_body -->

			<div class="jp_art_hero_caption">
				<div class="jp_art_hero_caption_inner">
					<span class="jp_caption_pill">
						Kantor Direktorat Bina Teknik Bangunan Gedung dan Penyehatan Lingkungan
					</span>
				</div>
			</div>
		{/if}
	</header><!-- .hero_card_fullwidth -->

	{* TOP 4 STATISTIC CARDS (MATCHING CLAUDE ARTIFACT 100%) *}
	{if !$requestedPage || $requestedPage === 'index'}
		<section class="jp_art_stat_cards_fullwidth" aria-label="Journal statistics">
			<div class="jp_art_stat_container">
				<div class="jp_art_stat_grid">
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box doc">
							<svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><path d="M14 3v6h6"></path><path d="M8 13h8"></path><path d="M8 17h6"></path></svg>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">228</div>
							<div class="jp_stat_title">Published Articles</div>
						</div>
					</div>
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box user">
							<svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="7" r="4"></circle><path d="M2 21v-1a6 6 0 0 1 10-4.5"></path><path d="M17.5 13.5l3 3L15 22h-3v-3z"></path></svg>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">387</div>
							<div class="jp_stat_title">Registered Authors</div>
						</div>
					</div>
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box issue">
							<svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3l9 5-9 5-9-5z"></path><path d="M3 13l9 5 9-5"></path><path d="M3 17.5l9 5 9-5"></path></svg>
						</div>
						<div class="jp_stat_info">
							<div class="jp_stat_number">37</div>
							<div class="jp_stat_title">Issues Published</div>
						</div>
					</div>
					<div class="jp_art_stat_card">
						<div class="jp_stat_icon_box download">
							<svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12"></path><path d="M7 10l5 5 5-5"></path><path d="M4 21h16"></path></svg>
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
