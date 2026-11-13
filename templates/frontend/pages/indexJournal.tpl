{**
 * templates/frontend/pages/indexJournal.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Display the index page for Jurnal Permukiman matching Claude Artifact Design:
 *        1. Current Issue Section (Left Column)
 *        2. Editorial Workflow & Speed Metrics (Left Column)
 *        3. Announcements Section (Left Column)
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName()}

<div class="page_index_journal">

	{call_hook name="Templates::Index::journal"}

	{* =========================================================================
	   1. CURRENT ISSUE (MAIN CONTENT SECTION)
	   ========================================================================= *}
	{if $issue}
		<section class="current_issue" aria-labelledby="currentIssueHeading">
			<div class="jp_art_section_header">
				<div>
					<div class="jp_art_section_tag">CURRENT ISSUE</div>
					<h2 id="currentIssueHeading" class="jp_art_section_title">
						{$issue->getIssueIdentification()|strip_unsafe_html}
					</h2>
				</div>
				<a href="{url page="issue" op="archive" router=$smarty.const.ROUTE_PAGE}" class="jp_art_view_all_link">
					View all issues &rarr;
				</a>
			</div>

			{* Issue Summary Banner (Cover + Description + Actions) *}
			<div class="jp_art_issue_hero">
				<div class="jp_art_issue_cover_wrap">
					{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
					{if $issueCover}
						<img src="{$issueCover|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:'Issue Cover'}" class="jp_art_issue_cover_img">
					{else}
						<div class="jp_art_issue_cover_placeholder">
							<div class="jp_cover_placeholder_title">JURNAL<br>PERMUKIMAN</div>
							<div class="jp_cover_placeholder_sub">Sampul issue<br>(aset resmi)</div>
						</div>
					{/if}
				</div>

				<div class="jp_art_issue_details">
					<div class="jp_art_issue_meta_line">
						{if $issue->getDatePublished()}
							<span>Published {$issue->getDatePublished()|date_format:$dateFormatShort}</span>
						{/if}
						{if $issueGalleys}
							&middot; <span>{$issueGalleys|@count} galley files</span>
						{/if}
					</div>
					<div class="jp_art_issue_desc">
						{if $issue->hasDescription()}
							{$issue->getLocalizedDescription()|strip_unsafe_html}
						{else}
							This issue presents empirical studies on public rental housing, livable settlements, green building technology, infrastructure development, and sanitation engineering.
						{/if}
					</div>
					<div class="jp_art_issue_actions">
						{if $issueGalleys}
							{foreach from=$issueGalleys item=galley}
								<a href="{url page="issue" op="view" path=$issue->getBestIssueId()|to_array:$galley->getBestGalleyId()}" class="jp_art_btn_full_issue">
									<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12"></path><path d="M7 10l5 5 5-5"></path><path d="M5 21h14"></path></svg>
									<span>Full issue (PDF)</span>
								</a>
							{/foreach}
						{else}
							<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}" class="jp_art_btn_full_issue">
								<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12"></path><path d="M7 10l5 5 5-5"></path><path d="M5 21h14"></path></svg>
								<span>Full issue (PDF)</span>
							</a>
						{/if}
					</div>
				</div>
			</div>

			{* Include issue table of contents (articles list) *}
			{include file="frontend/objects/issue_toc.tpl"}
		</section>
	{/if}

</div><!-- .page_index_journal -->

{capture assign="homepageSections"}
	{* =========================================================================
	   2. EDITORIAL WORKFLOW & JOURNAL PERFORMANCE STATISTICS (FULL WIDTH ROW)
	   ========================================================================= *}
	<section class="jp_art_workflow_section" aria-labelledby="editorialWorkflowHeading">
		<div class="jp_art_workflow_inner">
			<div>
				<div class="jp_art_section_tag">EDITORIAL WORKFLOW</div>
				<h2 id="editorialWorkflowHeading" class="jp_art_workflow_title">From submission to publication</h2>
			</div>

			{* 4 Step Process Cards *}
			<div class="jp_art_workflow_grid">
				<div class="jp_art_step_card">
					<div class="jp_step_badge">1</div>
					<h3 class="jp_step_title">Submission</h3>
					<p class="jp_step_desc">Authors submit the manuscript online using the official journal template.</p>
				</div>
				<div class="jp_art_step_card">
					<div class="jp_step_badge">2</div>
					<h3 class="jp_step_title">Editorial Screening</h3>
					<p class="jp_step_desc">Editors check scope, author guidelines, and initial Turnitin similarity check.</p>
				</div>
				<div class="jp_art_step_card">
					<div class="jp_step_badge">3</div>
					<h3 class="jp_step_title">Peer Review</h3>
					<p class="jp_step_desc">Manuscripts are evaluated through a rigorous double-blind peer review process.</p>
				</div>
				<div class="jp_art_step_card">
					<div class="jp_step_badge">4</div>
					<h3 class="jp_step_title">Publication</h3>
					<p class="jp_step_desc">Accepted articles are copyedited, assigned a Crossref DOI, and published Open Access.</p>
				</div>
			</div>

			{* Performance Insights Row (5 Matriks dari OJS & Claude Artifact) *}
			<div class="jp_art_perf_box">
				<div class="jp_art_perf_head">
					<h3 class="jp_art_perf_title">Journal Statistics</h3>
					<button type="button" class="jp_art_insights_btn" id="jpOpenInsightsBtn">
						View all insights &rarr;
					</button>
				</div>
				<div class="jp_art_perf_grid">
					<div class="jp_art_perf_item">
						<div class="jp_art_perf_val">43 days</div>
						<div class="jp_art_perf_lbl">Time to first decision</div>
					</div>
					<div class="jp_art_perf_item">
						<div class="jp_art_perf_val">57 days</div>
						<div class="jp_art_perf_lbl">Submission to acceptance</div>
					</div>
					<div class="jp_art_perf_item">
						<div class="jp_art_perf_val">15 days</div>
						<div class="jp_art_perf_lbl">Acceptance to publication</div>
					</div>
					<div class="jp_art_perf_item">
						<div class="jp_art_perf_val">79%</div>
						<div class="jp_art_perf_lbl">Acceptance rate (OJS)</div>
					</div>
					<div class="jp_art_perf_item">
						<div class="jp_art_perf_val">2 issues</div>
						<div class="jp_art_perf_lbl">Publication frequency / year</div>
					</div>
				</div>
			</div>
		</div>
	</section>

	{* =========================================================================
	   INSIGHTS MODAL OVERLAY
	   ========================================================================= *}
	<div id="jpInsightsModal" class="jp_insights_modal" role="dialog" aria-modal="true" aria-labelledby="jpInsightsModalTitle" hidden>
		<div class="jp_insights_backdrop" id="jpInsightsBackdrop"></div>
		<div class="jp_insights_dialog">
			<div class="jp_insights_dialog_head">
				<div>
					<h3 id="jpInsightsModalTitle">Jurnal Permukiman &mdash; Editorial &amp; Impact Insights</h3>
					<p>Transparansi metrik editorial dan performa penerbitan berbasis database OJS resmi.</p>
				</div>
				<button type="button" class="jp_insights_close" id="jpCloseInsightsBtn" aria-label="Close insights">&times;</button>
			</div>
			<div class="jp_insights_dialog_body">
				<div class="jp_insights_kpis">
					<div class="jp_kpi_box">
						<span class="jp_kpi_num">371</span>
						<span class="jp_kpi_title">Total Submissions</span>
					</div>
					<div class="jp_kpi_box">
						<span class="jp_kpi_num">228</span>
						<span class="jp_kpi_title">Published Articles</span>
					</div>
					<div class="jp_kpi_box">
						<span class="jp_kpi_num">389,159</span>
						<span class="jp_kpi_title">Abstract Views</span>
					</div>
					<div class="jp_kpi_box">
						<span class="jp_kpi_num">642,779</span>
						<span class="jp_kpi_title">PDF Downloads</span>
					</div>
				</div>
				<table class="jp_insights_table">
					<tbody>
						<tr>
							<td>Average Time to First Decision</td>
							<td><strong>43 days</strong> (6 weeks)</td>
						</tr>
						<tr>
							<td>Average Submission to Acceptance</td>
							<td><strong>57 days</strong> (8 weeks)</td>
						</tr>
						<tr>
							<td>Average Acceptance to Online Publication</td>
							<td><strong>15 days</strong> (2 weeks)</td>
						</tr>
						<tr>
							<td>Finalized Acceptance Rate</td>
							<td><strong>79%</strong> (228 accepted / 59 declined)</td>
						</tr>
						<tr>
							<td>Peer Review Method</td>
							<td><strong>Double-Blind Peer Review</strong> (2 independent reviewers)</td>
						</tr>
						<tr>
							<td>Publication Frequency &amp; Language</td>
							<td><strong>May &amp; November</strong> &middot; English-Only (since Jan 2026)</td>
						</tr>
						<tr>
							<td>License &amp; APC</td>
							<td><strong>CC BY-NC-ND 4.0</strong> &middot; Free of Charge (Rp 0)</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<script>
	(function () {
		var openBtn = document.getElementById('jpOpenInsightsBtn');
		var closeBtn = document.getElementById('jpCloseInsightsBtn');
		var backdrop = document.getElementById('jpInsightsBackdrop');
		var modal = document.getElementById('jpInsightsModal');
		if (!openBtn || !modal) return;
		function openModal() { modal.hidden = false; document.body.style.overflow = 'hidden'; }
		function closeModal() { modal.hidden = true; document.body.style.overflow = ''; }
		openBtn.addEventListener('click', openModal);
		if (closeBtn) closeBtn.addEventListener('click', closeModal);
		if (backdrop) backdrop.addEventListener('click', closeModal);
		document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !modal.hidden) closeModal(); });
	})();
	</script>

	{* =========================================================================
	   3. ANNOUNCEMENTS SECTION
	   ========================================================================= *}
	{if $numAnnouncementsHomepage && $announcements|@count}
		<section class="cmp_announcements" aria-labelledby="announcementsHeading">
			<div class="jp_art_section_header">
				<h2 id="announcementsHeading" class="jp_art_section_title">Announcements</h2>
				<a href="{url page="announcement" router=$smarty.const.ROUTE_PAGE}" class="jp_art_view_all_link">
					All announcements &rarr;
				</a>
			</div>
			<div class="jp_art_announcements_list">
				{foreach name=announcements from=$announcements item=announcement}
					{if $smarty.foreach.announcements.iteration > $numAnnouncementsHomepage}{break}{/if}
					<article class="jp_art_announcement_item">
						<div class="jp_art_announcement_date">
							{$announcement->getDatePosted()|date_format:"%d %B %Y"}
						</div>
						<div class="jp_art_announcement_body">
							<h3 class="jp_art_announcement_title">
								<a href="{url router=$smarty.const.ROUTE_PAGE page="announcement" op="view" path=$announcement->getId()}">
									{$announcement->getLocalizedTitle()|escape}
								</a>
							</h3>
							<div class="jp_art_announcement_desc">
								{$announcement->getLocalizedDescriptionShort()|strip_unsafe_html}
							</div>
						</div>
						<a href="{url router=$smarty.const.ROUTE_PAGE page="announcement" op="view" path=$announcement->getId()}" class="jp_art_read_more">
							Read more &rarr;
						</a>
					</article>
				{/foreach}
			</div>
		</section>
	{/if}
{/capture}

{include file="frontend/components/footer.tpl"}
