{**
 * templates/frontend/objects/issue_summary.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief View of an Issue which displays a summary for use in lists
 *
 * @uses $issue Issue The issue
 *}
{if $issue->getShowTitle()}
{assign var=issueTitle value=$issue->getLocalizedTitle()}
{/if}
{assign var=issueSeries value=$issue->getIssueSeries()}
{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}

<div class="obj_issue_summary">

	{if $issueCover}
		<a class="cover" href="{url op="view" path=$issue->getBestIssueId()}">
			<img src="{$issueCover|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:''}">
		</a>
	{else}
		<a class="cover cover_placeholder" href="{url op="view" path=$issue->getBestIssueId()}">
			<div class="jp_cover_placeholder_inner">
				<span class="jp_cover_placeholder_kemenpu">KEMENTERIAN PEKERJAAN UMUM</span>
				<span class="jp_cover_placeholder_title">JURNAL PERMUKIMAN</span>
				<div class="jp_cover_placeholder_divider"></div>
				<span class="jp_cover_placeholder_series">{if $issueTitle}{$issueTitle|escape}{else}{$issueSeries|escape}{/if}</span>
				<span class="jp_cover_placeholder_issn">e-ISSN 2339-2975</span>
			</div>
		</a>
	{/if}

	<h2>
		<a class="title" href="{url op="view" path=$issue->getBestIssueId()}">
			{if $issueTitle}
				{$issueTitle|escape}
			{else}
				{$issueSeries|escape}
			{/if}
		</a>
		{if $issueTitle && $issueSeries}
			<div class="series">
				{$issueSeries|escape}
			</div>
		{/if}
	</h2>

	{assign var=issueDescRaw value=$issue->getLocalizedDescription()|strip_unsafe_html}
	{assign var=issueDescPlain value=$issueDescRaw|strip_tags|replace:"&nbsp;":" "|replace:"&amp;":"&"|replace:"&quot;":'"'|replace:"&#39;":"'"|replace:"&apos;":"'"|replace:"&lt;":"<"|replace:"&gt;":">"|regex_replace:"/[\r\n\t\s]+/":" "|trim}
	{assign var=issueDescShort value=$issueDescPlain|truncate:140:"...":false}
	<div class="description">
		{if $issueDescPlain neq ""}
			{if $issueDescShort neq $issueDescPlain}
				<div class="jp_archive_desc_short">
					<p>{$issueDescShort|escape}</p>
				</div>
				<div class="jp_archive_desc_full" hidden>
					{$issueDescRaw}
				</div>
				<button type="button" class="jp_archive_read_all" aria-expanded="false">Read all</button>
			{else}
				{$issueDescRaw}
			{/if}
		{/if}
	</div>
</div><!-- .obj_issue_summary -->
