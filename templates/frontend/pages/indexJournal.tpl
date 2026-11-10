{**
 * templates/frontend/pages/indexJournal.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Display the index page for a journal with SINTA 2 badge & clean cards.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName()}

<div class="page_index_journal">

	{call_hook name="Templates::Index::journal"}

	{if !$activeTheme->getOption('useHomepageImageAsHeader') && $homepageImage}
		<div class="homepage_image">
			<img src="{$publicFilesDir}/{$homepageImage.uploadName|escape:"url"}"{if $homepageImage.altText} alt="{$homepageImage.altText|escape}"{/if}>
		</div>
	{/if}

	{* Journal Description *}
	{if $activeTheme->getOption('showDescriptionInJournalIndex')}
		<section class="homepage_about">
			<a id="homepageAbout"></a>
			<div class="section_title_header">
				<h2>{translate key="about.aboutContext"}</h2>
				<span class="badge_sinta2">
					<i class="fa fa-certificate" style="color: #C13D0D; font-size: 11px;"></i> Jurnal Terakreditasi SINTA 2
				</span>
			</div>
			{$currentContext->getLocalizedData('description')}
		</section>
	{/if}

	{* Announcements *}
	{if $numAnnouncementsHomepage && $announcements|@count}
		<section class="cmp_announcements highlight_first">
			<a id="homepageAnnouncements"></a>
			<h2>
				{translate key="announcement.announcements"}
			</h2>
			<div class="announcements_list">
			{foreach name=announcements from=$announcements item=announcement}
				{if $smarty.foreach.announcements.iteration > $numAnnouncementsHomepage}
					{break}
				{/if}
				{if $smarty.foreach.announcements.iteration == 1}
					<article class="obj_announcement_summary highlight_card">
						<div class="announcement_meta_row">
							<h3>
								<a href="{url router=$smarty.const.ROUTE_PAGE page="announcement" op="view" path=$announcement->getId()}">
									<i class="fa fa-bullhorn" style="color: #C13D0D; margin-right: 6px;"></i>
									{$announcement->getLocalizedTitle()|escape}
								</a>
							</h3>
							<span class="date_badge">{$announcement->getDatePosted()|date_format:$dateFormatShort}</span>
						</div>
						<div class="description">
							{$announcement->getLocalizedDescriptionShort()|strip_unsafe_html}
						</div>
					</article>
				{else}
					<article class="obj_announcement_summary standard_card">
						<div class="standard_card_left">
							<i class="fa fa-file-text-o" style="color: #94A3B8; font-size: 15px; margin-right: 12px;"></i>
							<div class="standard_card_text">
								<h4>
									<a href="{url router=$smarty.const.ROUTE_PAGE page="announcement" op="view" path=$announcement->getId()}">
										{$announcement->getLocalizedTitle()|escape}
									</a>
								</h4>
								<span class="date_posted">Dipublikasikan: {$announcement->getDatePosted()|date_format:$dateFormatShort}</span>
							</div>
						</div>
						<i class="fa fa-angle-right chevron_right" style="color: #94A3B8; font-size: 14px;"></i>
					</article>
				{/if}
			{/foreach}
			</div>
		</section>
	{/if}

	{* Latest issue *}
	{if $issue}
		<section class="current_issue">
			<a id="homepageIssue"></a>
			<h2>
				{translate key="journal.currentIssue"}
			</h2>
			<div class="current_issue_title">
				{$issue->getIssueIdentification()|strip_unsafe_html}
			</div>
			{include file="frontend/objects/issue_toc.tpl" heading="h3"}
			<a href="{url router=$smarty.const.ROUTE_PAGE page="issue" op="archive"}" class="read_more">
				{translate key="journal.viewAllIssues"}
			</a>
		</section>
	{/if}

	{* Additional Homepage Content *}
	{if $additionalHomeContent}
		<div class="additional_content">
			{$additionalHomeContent}
		</div>
	{/if}
</div><!-- .page -->

{include file="frontend/components/footer.tpl"}
