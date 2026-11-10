{**
 * templates/frontend/components/header.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Common frontend site header with Puskim Ecosystem Quick Access (MQC & JP).
 *}
{strip}
	{* Determine whether a logo or title string is being displayed *}
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

	<div class="pkp_structure_page">

		{* Header *}
		<header class="pkp_structure_head" id="headerNavigationContainer" role="banner">
			{* Skip to content nav links *}
			{include file="frontend/components/skipLinks.tpl"}

			<div class="pkp_head_wrapper">

				{* TOP UTILITY BAR (PERSIS MOCKUP) *}
				<div class="pkp_top_utility_bar">
					<div class="pkp_top_utility_left">
						<i class="fa fa-university text-brick" style="color: #C13D0D; margin-right: 6px;"></i>
						<span>Balai Sains Bangunan dan Permukiman, Bandung</span>
					</div>
					<div class="pkp_top_utility_right">
						{if $isUserLoggedIn}
							<a href="{url page="submissions" router=$smarty.const.ROUTE_PAGE}" class="utility_link font-bold">
								<i class="fa fa-user" style="color: #C13D0D;"></i>
								<span>{$currentUser->getUsername()|escape} (Dashboard)</span>
							</a>
							<span class="utility_divider">|</span>
							<a href="{url page="login" op="signOut" router=$smarty.const.ROUTE_PAGE}" class="utility_link">
								<i class="fa fa-sign-out"></i>
								<span>Logout</span>
							</a>
						{else}
							<a href="{url page="user" op="register" router=$smarty.const.ROUTE_PAGE}" class="utility_link">
								<i class="fa fa-user-plus" style="color: #C13D0D;"></i>
								<span>Register</span>
							</a>
							<span class="utility_divider">|</span>
							<a href="{url page="login" router=$smarty.const.ROUTE_PAGE}" class="utility_link">
								<i class="fa fa-sign-in" style="color: #C13D0D;"></i>
								<span>Login</span>
							</a>
						{/if}
					</div>
				</div>

				<div class="pkp_site_name_wrapper">
					<button class="pkp_site_nav_toggle">
						<span>Open Menu</span>
					</button>
					{if !$requestedPage || $requestedPage === 'index'}
						<h1 class="pkp_screen_reader">
							{if $currentContext}
								{$displayPageHeaderTitle|escape}
							{else}
								{$siteTitle|escape}
							{/if}
						</h1>
					{/if}
					<div class="pkp_site_name">
					{capture assign="homeUrl"}
						{url page="index" router=$smarty.const.ROUTE_PAGE}
					{/capture}
					{if $displayPageHeaderLogo}
						<a href="{$homeUrl}" class="is_img">
							<img src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}" width="{$displayPageHeaderLogo.width|escape}" height="{$displayPageHeaderLogo.height|escape}" {if $displayPageHeaderLogo.altText != ''}alt="{$displayPageHeaderLogo.altText|escape}"{/if} />
						</a>
					{elseif $displayPageHeaderTitle}
						<a href="{$homeUrl}" class="is_text">{$displayPageHeaderTitle|escape}</a>
					{else}
						<a href="{$homeUrl}" class="is_img">
							<img src="{$baseUrl}/templates/images/structure/logo.png" alt="{$applicationName|escape}" title="{$applicationName|escape}" width="180" height="90" />
						</a>
					{/if}
					</div>
				</div>

				{capture assign="primaryMenu"}
					{load_menu name="primary" id="navigationPrimary" ulClass="pkp_navigation_primary"}
				{/capture}

				<nav class="pkp_site_nav_menu" aria-label="{translate|escape key="common.navigation.site"}">
					<a id="siteNav"></a>
					<div class="pkp_navigation_primary_row">
						<div class="pkp_navigation_primary_wrapper">
							<a href="{$homeUrl}" class="nav_home_capsule">
								<i class="fa fa-home"></i> <span>Home</span>
							</a>
							{* Primary navigation menu for current application *}
							{$primaryMenu}
						</div>

						{* Search form & Quick Access *}
						<div class="pkp_navigation_right_tools">
							{if $currentContext && $requestedPage !== 'search'}
								<div class="pkp_navigation_search_wrapper">
									<form class="pkp_search_form" action="{url page="search" op="search" router=$smarty.const.ROUTE_PAGE}" method="post">
										{csrf}
										<div class="search_input_wrap">
											<i class="fa fa-search search_icon"></i>
											<input type="text" name="query" placeholder="Search articles..." class="search_input_field">
										</div>
									</form>
								</div>
							{/if}

							{* Ecosystem Quick Access Buttons: MQC & JP *}
							<div class="jp_ecosystem_nav_links">
								<a href="http://{$smarty.server.SERVER_NAME|default:'localhost'}:3000" target="_blank" rel="noopener noreferrer" class="jp_ecosystem_btn mqc" title="Akses MQC Assistant (Pemeriksaan Kepatuhan Naskah)">
									<span>MQC</span>
									<span class="fa fa-external-link" aria-hidden="true"></span>
								</a>
								<a href="http://{$smarty.server.SERVER_NAME|default:'localhost'}:3001" target="_blank" rel="noopener noreferrer" class="jp_ecosystem_btn jp" title="Akses JP-Insight (Knowledge System & RAG)">
									<span>JP</span>
									<span class="fa fa-external-link" aria-hidden="true"></span>
								</a>
							</div>
						</div>
					</div>
				</nav>
			</div><!-- .pkp_head_wrapper -->
		</header><!-- .pkp_structure_head -->

		{* Wrapper for page content and sidebars *}
		{if $isFullWidth}
			{assign var=hasSidebar value=0}
		{/if}
		<div class="pkp_structure_content{if $hasSidebar} has_sidebar{/if}">
			<div class="pkp_structure_main" role="main">
				<a id="pkp_content_main"></a>
