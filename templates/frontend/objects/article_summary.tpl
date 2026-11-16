{**
 * templates/frontend/objects/article_summary.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief View of an Article summary matching Claude Artifact design:
 *        Clean warm border, Lora title, DOI badge, PDF pill, and views/downloads counters.
 *}
{assign var=articlePath value=$article->getBestId()}
{if !$heading}
	{assign var="heading" value="h3"}
{/if}

{if (!$section.hideAuthor && $article->getHideAuthor() == $smarty.const.AUTHOR_TOC_DEFAULT) || $article->getHideAuthor() == $smarty.const.AUTHOR_TOC_SHOW}
	{assign var="showAuthor" value=true}
{/if}

{assign var=publication value=$article->getCurrentPublication()}
{assign var=submissionPages value=$publication->getData('pages')}
{assign var=submissionDatePublished value=$publication->getData('datePublished')}
{assign var=articleDoi value=$publication->getStoredPubId('doi')}
{assign var=abstractViews value=$article->getViews()}
{assign var=totalGalleyViews value=0}
{foreach from=$article->getGalleys() item=galley}
	{assign var=totalGalleyViews value=$totalGalleyViews+$galley->getViews()}
{/foreach}

<article class="obj_article_summary jp_art_article_card">
	<div class="jp_art_article_top">
		<{$heading} class="title jp_art_article_title">
			<a id="article-{$article->getId()}" {if $journal}href="{url journal=$journal->getPath() page="article" op="view" path=$articlePath}"{else}href="{url page="article" op="view" path=$articlePath}"{/if}>
				{$article->getLocalizedTitle()|strip_unsafe_html}
				{if $article->getLocalizedSubtitle()}
					<span class="subtitle">{$article->getLocalizedSubtitle()|escape}</span>
				{/if}
			</a>
		</{$heading}>
		{if $submissionPages}
			<span class="jp_art_pages">pp. {$submissionPages|escape}</span>
		{/if}
	</div>

	{if $showAuthor}
		<div class="jp_art_authors">
			{$article->getAuthorString()|escape}
		</div>
	{/if}

	<div class="jp_art_article_meta_row">
		{* PDF Button *}
		{if !$hideGalleys && $article->getGalleys()}
			<div class="jp_art_galleys">
				{foreach from=$article->getGalleys() item=galley}
					{assign var="hasArticleAccess" value=$hasAccess}
					{if $currentContext->getSetting('publishingMode') == $smarty.const.PUBLISHING_MODE_OPEN || $publication->getData('accessStatus') == $smarty.const.ARTICLE_ACCESS_OPEN}
						{assign var="hasArticleAccess" value=1}
					{/if}
					<a class="jp_art_pdf_btn" href="{url page="article" op="view" path=$articlePath|to_array:$galley->getBestGalleyId()}">
						<i class="fa fa-file-pdf-o" aria-hidden="true"></i>
						<span>{$galley->getGalleyLabel()|escape|default:"PDF"}</span>
					</a>
				{/foreach}
			</div>
		{/if}

		{* Counters *}
		<span class="jp_art_metric_stat">
			<i class="fa fa-bar-chart" style="color: #0E7490;"></i>
			<span>Abstract views: <strong>{$abstractViews|default:0|number_format:0:",":"."}</strong></span>
		</span>
		<span class="jp_art_metric_stat">
			<i class="fa fa-download" style="color: #6366F1;"></i>
			<span>PDF downloads: <strong>{$totalGalleyViews|default:0|number_format:0:",":"."}</strong></span>
		</span>

		{* DOI Link *}
		{if $articleDoi}
			<a href="https://doi.org/{$articleDoi|escape}" target="_blank" rel="noopener" class="jp_art_doi_pill">
				<span class="jp_doi_dot">doi</span>
				<span>https://doi.org/{$articleDoi|escape}</span>
			</a>
		{/if}
	</div>

	{call_hook name="Templates::Issue::Issue::Article"}
</article>
