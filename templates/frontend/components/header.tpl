{**
 * templates/frontend/components/header.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Common frontend site header matching Mockup_Redesign_Ecosystem_JP.html 100%.
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

{* INLINE EMBEDDED STYLES FOR ZERO CLIENT CACHE FRICTION *}
<style>
  /* RESET & BODY BACKGROUND RADIAL MERAH BATA */
  body, html {
    font-family: 'Plus Jakarta Sans', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif !important;
    background-color: #C13D0D !important;
    background-image: radial-gradient(circle at 50% 0%, #C84313 0%, #9C2E07 100%) !important;
    background-attachment: fixed !important;
    margin: 0 !important;
    padding: 0 !important;
    color: #1E293B !important;
  }

  /* WADAH UTAMA KARTU PUTIH FLOATING 1240PX */
  .pkp_structure_page {
    max-width: 1240px !important;
    width: 95% !important;
    margin: 24px auto !important;
    background: #FFFFFF !important;
    border-radius: 16px !important;
    box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.35), 0 0 0 1px rgba(255, 255, 255, 0.25) !important;
    padding: 24px !important;
    box-sizing: border-box !important;
  }

  /* MATIKAN CLEARFIX THEME LAMA */
  .pkp_structure_page:before, .pkp_structure_page:after,
  .pkp_head_wrapper:before, .pkp_head_wrapper:after,
  .pkp_site_name_wrapper:before, .pkp_site_name_wrapper:after,
  .pkp_navigation_primary_wrapper:before, .pkp_navigation_primary_wrapper:after,
  .pkp_navigation_primary_row:before, .pkp_navigation_primary_row:after,
  .pkp_structure_content:before, .pkp_structure_content:after,
  .pkp_structure_main:before, .pkp_structure_main:after {
    display: none !important;
    content: none !important;
  }

  /* HEADER CARD */
  .pkp_structure_head {
    background: transparent !important;
    border: none !important;
    padding: 0 !important;
    margin-bottom: 24px !important;
  }
  .pkp_head_wrapper {
    background: #FFFFFF !important;
    border-radius: 16px !important;
    border: 1px solid rgba(226, 232, 240, 0.8) !important;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05) !important;
    overflow: hidden !important;
    margin: 0 !important;
    padding: 0 !important;
  }

  /* BAR UTILITAS ATAS */
  .pkp_top_utility_bar {
    background: rgba(248, 250, 252, 0.95) !important;
    padding: 9px 24px !important;
    border-bottom: 1px solid #F1F5F9 !important;
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    font-size: 13px !important;
    color: #475569 !important;
  }
  .pkp_top_utility_left {
    display: flex !important;
    align-items: center !important;
    gap: 8px !important;
    font-weight: 500 !important;
    color: #334155 !important;
  }
  .pkp_top_utility_right {
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
  }
  .pkp_top_utility_right a {
    color: #475569 !important;
    text-decoration: none !important;
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    transition: color 0.15s ease !important;
  }
  .pkp_top_utility_right a:hover {
    color: #C13D0D !important;
  }
  .pkp_top_utility_right .utility_divider {
    color: #CBD5E1 !important;
  }

  /* BANNER WALL TO WALL */
  .pkp_site_name_wrapper {
    width: 100% !important;
    line-height: 0 !important;
    margin: 0 !important;
    padding: 0 !important;
    background: #FFFFFF !important;
  }
  .pkp_site_name, .pkp_site_name a.is_img {
    display: block !important;
    width: 100% !important;
    margin: 0 !important;
    padding: 0 !important;
    line-height: 0 !important;
  }
  .pkp_site_name a.is_img img {
    width: 100% !important;
    height: auto !important;
    display: block !important;
    border: none !important;
  }

  /* BILAH NAVIGASI MERAH BATA DENGAN HIGHLIGHT HOME */
  .pkp_site_nav_menu {
    background: linear-gradient(135deg, #C13D0D 0%, #A5330A 100%) !important;
    color: #FFFFFF !important;
    padding: 6px 24px !important;
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1) !important;
  }
  .bata_nav_left {
    display: flex !important;
    align-items: center !important;
    gap: 6px !important;
    font-size: 14px !important;
    font-weight: 700 !important;
  }
  .bata_nav_left a {
    color: rgba(255, 255, 255, 0.9) !important;
    text-decoration: none !important;
    padding: 6px 14px !important;
    border-radius: 8px !important;
    transition: all 0.15s ease !important;
    font-weight: 700 !important;
  }
  .bata_nav_left a:hover {
    background: rgba(0, 0, 0, 0.2) !important;
    color: #FFFFFF !important;
  }
  .bata_nav_left a.nav_home_capsule {
    background: rgba(0, 0, 0, 0.25) !important;
    color: #FFFFFF !important;
    font-weight: 800 !important;
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.2) !important;
  }

  .bata_nav_search {
    position: relative !important;
    width: 230px !important;
  }
  .bata_nav_search input {
    width: 100% !important;
    box-sizing: border-box !important;
    background: rgba(255, 255, 255, 0.2) !important;
    color: #FFFFFF !important;
    border: 1px solid rgba(255, 255, 255, 0.3) !important;
    border-radius: 8px !important;
    padding: 6px 12px 6px 32px !important;
    font-size: 12px !important;
    outline: none !important;
    transition: all 0.15s ease !important;
  }
  .bata_nav_search input::placeholder {
    color: rgba(255, 255, 255, 0.8) !important;
  }
  .bata_nav_search input:focus {
    background: #FFFFFF !important;
    color: #1E293B !important;
  }
  .bata_nav_search input:focus::placeholder {
    color: #94A3B8 !important;
  }
  .bata_nav_search .search_icon {
    position: absolute !important;
    left: 10px !important;
    top: 50% !important;
    transform: translateY(-50%) !important;
    color: rgba(255, 255, 255, 0.8) !important;
    font-size: 12px !important;
    pointer-events: none !important;
  }
  .bata_nav_search input:focus + .search_icon {
    color: #C13D0D !important;
  }

  /* LAYOUT 2 KOLOM KONTEN KIRI & SIDEBAR KANAN */
  .pkp_structure_content {
    display: flex !important;
    flex-direction: row !important;
    justify-content: space-between !important;
    align-items: flex-start !important;
    gap: 28px !important;
    width: 100% !important;
    padding: 0 !important;
    margin: 0 !important;
    float: none !important;
  }
  .pkp_structure_main {
    flex: 1 1 65% !important;
    width: 65% !important;
    min-width: 0 !important;
    float: none !important;
    margin: 0 !important;
    padding: 0 !important;
  }
  .pkp_sidebar {
    flex: 0 0 32% !important;
    width: 32% !important;
    max-width: 380px !important;
    min-width: 300px !important;
    float: none !important;
    margin: 0 !important;
    padding: 0 !important;
  }

  /* KARTU PUTIH INDIVIDUAL SEGAR */
  .fresh-card, .homepage_about, .cmp_announcements, .current_issue, .pkp_block {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 14px !important;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04), 0 4px 12px rgba(193, 61, 13, 0.03) !important;
    padding: 24px 28px !important;
    margin-bottom: 24px !important;
    box-sizing: border-box !important;
  }
  .pkp_block {
    padding: 16px !important;
    margin-bottom: 20px !important;
    border-radius: 12px !important;
  }

  /* JUDUL SEKSI DENGAN AKSI MERAH BATA */
  .section_title_header, .cmp_announcements h2, .current_issue h2 {
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    border-bottom: 2px solid rgba(193, 61, 13, 0.2) !important;
    padding-bottom: 12px !important;
    margin: 0 0 16px 0 !important;
  }
  .section_title_header h2, .cmp_announcements h2, .current_issue h2 {
    font-size: 18px !important;
    font-weight: 800 !important;
    color: #0F172A !important;
    letter-spacing: -0.01em !important;
    margin: 0 !important;
    display: inline-flex !important;
    align-items: center !important;
  }
  .section_title_header h2::before, .cmp_announcements h2::before, .current_issue h2::before {
    content: '' !important;
    display: inline-block !important;
    width: 7px !important;
    height: 20px !important;
    background: #C13D0D !important;
    border-radius: 9999px !important;
    margin-right: 10px !important;
  }

  /* BADGE SINTA 2 */
  .badge_sinta2 {
    font-size: 11.5px !important;
    font-weight: 700 !important;
    color: #C13D0D !important;
    background: #FDF4F0 !important;
    border: 1px solid #F4D4C9 !important;
    padding: 3.5px 12px !important;
    border-radius: 9999px !important;
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
  }

  /* TABEL IDENTITAS JURNAL */
  .homepage_about table {
    width: 100% !important;
    border-collapse: separate !important;
    border-spacing: 0 !important;
    border: 1px solid rgba(226, 232, 240, 0.8) !important;
    border-radius: 12px !important;
    overflow: hidden !important;
    margin-top: 16px !important;
    background: rgba(248, 250, 252, 0.5) !important;
  }
  .homepage_about table tr {
    border-bottom: 1px solid rgba(226, 232, 240, 0.7) !important;
  }
  .homepage_about table tr:last-child {
    border-bottom: none !important;
  }
  .homepage_about table td {
    padding: 10px 16px !important;
    font-size: 14px !important;
    border-bottom: 1px solid rgba(226, 232, 240, 0.7) !important;
  }
  .homepage_about table tr:last-child td {
    border-bottom: none !important;
  }
  .homepage_about table td:first-child {
    background: rgba(241, 245, 249, 0.7) !important;
    font-weight: 700 !important;
    color: #334155 !important;
    width: 35% !important;
  }
  .homepage_about table td:last-child {
    background: transparent !important;
    color: #1E293B !important;
  }
  .homepage_about table td p {
    margin: 0 !important;
    padding: 0 !important;
  }
  .homepage_about table a {
    color: #C13D0D !important;
    font-family: monospace !important;
    font-weight: 700 !important;
    text-decoration: none !important;
  }

  /* ANNOUNCEMENTS: HIGHLIGHT CARD & LIST ROW */
  .announcements_list {
    display: flex !important;
    flex-direction: column !important;
    gap: 12px !important;
  }
  .highlight_card {
    background: #FDF4F0 !important;
    border: 1px solid #F4D4C9 !important;
    border-radius: 12px !important;
    padding: 18px 20px !important;
  }
  .highlight_card .announcement_meta_row {
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    margin-bottom: 8px !important;
  }
  .highlight_card h3 {
    margin: 0 !important;
    font-size: 15px !important;
    font-weight: 800 !important;
    line-height: 1.4 !important;
  }
  .highlight_card h3 a {
    color: #C13D0D !important;
    text-decoration: none !important;
  }
  .highlight_card .date_badge {
    font-size: 12px !important;
    font-family: monospace !important;
    font-weight: 600 !important;
    color: #64748B !important;
  }
  .highlight_card .description {
    font-size: 13.5px !important;
    color: #334155 !important;
    line-height: 1.6 !important;
    margin: 0 !important;
  }
  .standard_card {
    background: #FFFFFF !important;
    border: 1px solid rgba(226, 232, 240, 0.8) !important;
    border-radius: 12px !important;
    padding: 12px 18px !important;
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    transition: all 0.15s ease !important;
  }
  .standard_card:hover {
    background: #F8FAFC !important;
    border-color: #CBD5E1 !important;
  }
  .standard_card h4 {
    margin: 0 !important;
    font-size: 13.5px !important;
    font-weight: 600 !important;
  }
  .standard_card h4 a {
    color: #1E293B !important;
    text-decoration: none !important;
  }
  .standard_card_right {
    display: flex !important;
    align-items: center !important;
    gap: 12px !important;
    font-size: 12px !important;
    color: #64748B !important;
  }
  .standard_card_right .chevron_right {
    font-size: 14px !important;
    color: #94A3B8 !important;
  }

  /* SIDEBAR: BLOCK TITLE */
  .pkp_block .title {
    font-size: 12px !important;
    font-weight: 800 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.05em !important;
    color: #1E293B !important;
    border-bottom: 2px solid rgba(193, 61, 13, 0.3) !important;
    padding-bottom: 8px !important;
    margin: 0 0 12px 0 !important;
  }

  /* MAKE A SUBMISSION */
  .block_make_submission .content a {
    display: flex !important;
    flex-direction: column !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 14px 16px !important;
    background: linear-gradient(135deg, #C13D0D 0%, #A0320A 100%) !important;
    border-radius: 12px !important;
    color: #FFFFFF !important;
    text-decoration: none !important;
    box-shadow: 0 4px 12px rgba(193, 61, 13, 0.25) !important;
    text-align: center !important;
    transition: all 0.18s ease !important;
    font-size: 0 !important;
  }
  .block_make_submission .content a:hover {
    transform: translateY(-2px) !important;
    box-shadow: 0 6px 16px rgba(193, 61, 13, 0.35) !important;
  }
  .block_make_submission .content a::before {
    content: '\f1d8  MAKE A SUBMISSION' !important;
    font-family: FontAwesome, 'Plus Jakarta Sans', sans-serif !important;
    font-size: 14px !important;
    font-weight: 800 !important;
    letter-spacing: 0.05em !important;
    text-transform: uppercase !important;
    display: block !important;
    margin-bottom: 2px !important;
  }
  .block_make_submission .content a::after {
    content: 'Submit your research manuscript online' !important;
    font-family: 'Plus Jakarta Sans', sans-serif !important;
    font-size: 11px !important;
    font-weight: 400 !important;
    color: rgba(255, 255, 255, 0.85) !important;
    display: block !important;
  }
  .block_make_submission .content a span, .block_make_submission .content a i {
    display: none !important;
  }

  /* REGISTRATION BLOCK */
  .registration_cta_btn {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    gap: 8px !important;
    width: 100% !important;
    box-sizing: border-box !important;
    padding: 10px 14px !important;
    background: #1E293B !important;
    border-radius: 8px !important;
    color: #FFFFFF !important;
    font-size: 12.5px !important;
    font-weight: 700 !important;
    text-decoration: none !important;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05) !important;
    transition: all 0.15s ease !important;
  }
  .registration_cta_btn:hover {
    background: #0F172A !important;
    color: #FFFFFF !important;
  }

  /* JOURNAL POLICY (18 MENU) */
  #customblock-journal-police .title {
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
  }
  #customblock-journal-police .title::after {
    content: '18 Menu Resmi' !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    color: #C13D0D !important;
    background: #FDF4F0 !important;
    border: 1px solid #F4D4C9 !important;
    padding: 2px 8px !important;
    border-radius: 9999px !important;
    text-transform: none !important;
    letter-spacing: normal !important;
  }

  .policy_menu_stack {
    display: flex !important;
    flex-direction: column !important;
    gap: 3.5px !important;
  }
  .policy-bata-btn {
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    padding: 8.5px 12px !important;
    border-radius: 6px !important;
    font-size: 13.5px !important;
    font-weight: 600 !important;
    color: #FFFFFF !important;
    background: #C13D0D !important;
    border: 1px solid rgba(255, 255, 255, 0.15) !important;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.08) !important;
    transition: all 0.18s cubic-bezier(0.16, 1, 0.3, 1) !important;
    text-decoration: none !important;
  }
  .policy-bata-btn:hover {
    background: #A0320A !important;
    transform: translateX(4px) !important;
    box-shadow: 0 4px 10px rgba(193, 61, 13, 0.35) !important;
    color: #FFFFFF !important;
  }
  .policy-bata-btn.home-btn {
    background: #778899 !important;
    border-color: rgba(255, 255, 255, 0.2) !important;
  }
  .policy-bata-btn.home-btn:hover {
    background: #5A6978 !important;
    box-shadow: 0 4px 10px rgba(119, 136, 153, 0.4) !important;
  }
  .policy-bata-btn .btn_label {
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
  }
  .policy-bata-btn .btn_label i {
    width: 16px !important;
    text-align: center !important;
  }
  .policy-bata-btn .chevron_icon {
    font-size: 12px !important;
    opacity: 0.75 !important;
  }

  /* FOOTER */
  .pkp_structure_footer_wrapper {
    background: transparent !important;
    border-top: 1px solid #E2E8F0 !important;
    padding: 24px 0 8px !important;
    margin-top: 32px !important;
    font-size: 12.5px !important;
    color: #64748B !important;
  }
  .pkp_structure_footer_wrapper a {
    color: #C13D0D !important;
  }
</style>

<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"}{if $showingLogo} has_site_logo{/if}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

	<div class="pkp_structure_page">

		{* Header *}
		<header class="pkp_structure_head" id="headerNavigationContainer" role="banner">
			{* Skip to content nav links *}
			{include file="frontend/components/skipLinks.tpl"}

			<div class="pkp_head_wrapper">

				{* BAR UTILITAS ATAS PERSIS MOCKUP *}
				<div class="pkp_top_utility_bar">
					<div class="pkp_top_utility_left">
						<i class="fa fa-university text-brick" style="color: #C13D0D;"></i>
						<span>Balai Sains Bangunan dan Permukiman, Bandung</span>
					</div>
					<div class="pkp_top_utility_right">
						{if $isUserLoggedIn}
							<a href="{url page="submissions" router=$smarty.const.ROUTE_PAGE}" class="font-bold">
								<i class="fa fa-user" style="color: #C13D0D;"></i>
								<span>{$currentUser->getUsername()|escape} (Dashboard)</span>
							</a>
							<span class="utility_divider">|</span>
							<a href="{url page="login" op="signOut" router=$smarty.const.ROUTE_PAGE}">
								<i class="fa fa-sign-out" style="color: #C13D0D;"></i>
								<span>Logout</span>
							</a>
						{else}
							<a href="{url page="user" op="register" router=$smarty.const.ROUTE_PAGE}">
								<i class="fa fa-user-plus" style="color: #C13D0D;"></i>
								<span>Register</span>
							</a>
							<span class="utility_divider">|</span>
							<a href="{url page="login" router=$smarty.const.ROUTE_PAGE}">
								<i class="fa fa-sign-in" style="color: #C13D0D;"></i>
								<span>Login</span>
							</a>
						{/if}
					</div>
				</div>

				{* BANNER WALL TO WALL PERSIS MOCKUP *}
				<div class="pkp_site_name_wrapper">
					{capture assign="homeUrl"}
						{url page="index" router=$smarty.const.ROUTE_PAGE}
					{/capture}
					<div class="pkp_site_name">
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

				{* BILAH NAVIGASI PERSIS MOCKUP *}
				<nav class="pkp_site_nav_menu" aria-label="{translate|escape key="common.navigation.site"}">
					<a id="siteNav"></a>
					<div class="bata_nav_left">
						<a href="{$homeUrl}" class="nav_home_capsule">
							<i class="fa fa-home"></i> <span>Home</span>
						</a>
						<a href="{url page="about" router=$smarty.const.ROUTE_PAGE}">About</a>
						<a href="{url page="issue" op="current" router=$smarty.const.ROUTE_PAGE}">Current</a>
						<a href="{url page="announcement" router=$smarty.const.ROUTE_PAGE}">Announcements</a>
						<a href="{url page="issue" op="archive" router=$smarty.const.ROUTE_PAGE}">Archives</a>
						<a href="{url page="about" op="contact" router=$smarty.const.ROUTE_PAGE}">Contact</a>
					</div>

					<div class="bata_nav_search">
						<form action="{url page="search" op="search" router=$smarty.const.ROUTE_PAGE}" method="post" style="margin: 0; padding: 0;">
							{csrf}
							<input type="text" name="query" placeholder="Search articles...">
							<i class="fa fa-search search_icon"></i>
						</form>
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
