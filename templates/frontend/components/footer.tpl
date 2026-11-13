{**
 * templates/frontend/components/footer.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief Common site frontend footer matching Claude Artifact Design:
 *        Gold top border (5px solid #F5B335), Deep Rust container (#7A2E0E),
 *        4 clean navigation columns, and bottom CC license bar.
 *}

	</div><!-- pkp_structure_main -->

	{* Sidebars *}
	{if empty($isFullWidth)}
		{capture assign="sidebarCode"}{call_hook name="Templates::Common::Sidebar"}{/capture}
		{if $sidebarCode}
			<div class="pkp_structure_sidebar left" role="complementary" aria-label="{translate|escape key="common.navigation.sidebar"}">
				{$sidebarCode}
			</div><!-- pkp_sidebar.left -->
		{/if}
	{/if}
</div><!-- pkp_structure_content -->

{if $homepageSections}
	{$homepageSections}
{/if}

<footer class="jp_art_footer_root" role="contentinfo">
	<a id="pkp_content_footer"></a>

	<div class="jp_art_footer_card">
		<div class="jp_art_footer_columns">
			{* Column 1: For Authors *}
			<div class="jp_art_footer_col">
				<h2 class="jp_art_col_title">FOR AUTHORS</h2>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="about" op="submissions"}#authorGuidelines">Author Guidelines</a>
				<a href="https://docs.google.com/document/d/1IlqANma92RPqcnfOjiw4OpAjgtwyxBoc/preview" target="_blank" rel="noopener">Article Template</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="copyrightnoticeandlicensing"}">Copyright Notice and Licensing</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="ArticleProcessingCharge"}">Article Processing Charge (APC)</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="AIPolicy"}">Generative AI Policy</a>
			</div>

			{* Column 2: Editorial Policies *}
			<div class="jp_art_footer_col">
				<h2 class="jp_art_col_title">EDITORIAL POLICIES</h2>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="publicationEthics"}">Publication Ethics</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="PlagiarismCheck"}">Plagiarism Check</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="ArticleRetractionWithdrawal"}">Article Retraction &amp; Withdrawal</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="ComplaintsandAppealsPolicy"}">Complaints and Appeals Policy</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="PostPublicationDiscussion"}">Post-Publication Discussion</a>
			</div>

			{* Column 3: For Reviewers *}
			<div class="jp_art_footer_col">
				<h2 class="jp_art_col_title">FOR REVIEWERS</h2>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="kebijakanreview"}">Peer Review Process</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="PeerReview"}">Peer Reviewers</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="publicationEthics"}">Publication Ethics</a>
			</div>

			{* Column 4: About Jurnal Permukiman *}
			<div class="jp_art_footer_col">
				<h2 class="jp_art_col_title">ABOUT JURNAL PERMUKIMAN</h2>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="fokus"}">Aims and Scope</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="about" op="editorialTeam"}">Editorial Team</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="indexing"}">Abstracting and Indexing</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="OpenAccessPolicy"}">Open Access Policy</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="PublicationFrequency"}">Publication Frequency</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="ArchivingPolicy"}">Archiving Policy</a>
				<a href="{url router=$smarty.const.ROUTE_PAGE page="stats"}">Journal Statistics</a>
			</div>
		</div>

		{* Bottom Bar: License & Contact *}
		<div class="jp_art_footer_bottom">
			<div class="jp_art_bottom_text">
				<div>The content of this website is licensed under a <a href="http://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" rel="noopener">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.</div>
				<div>e-ISSN <strong style="color:#FFFFFF;">2339-2975</strong> (online) &nbsp;|&nbsp; Jalan Panyawungan, Cileunyi Wetan, Cileunyi, Bandung, West Java 40622 &nbsp;|&nbsp; <a href="mailto:jurnalpermukiman@pu.go.id">jurnalpermukiman@pu.go.id</a></div>
			</div>
			<a href="http://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" rel="noopener" class="jp_art_cc_badge">
				<img src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" alt="Creative Commons License CC BY-NC-ND 4.0">
			</a>
		</div>
	</div>
</footer>

</div><!-- .pkp_structure_page -->

{load_script context="frontend"}

{call_hook name="Templates::Common::Footer::PageFooter"}
<script src="{$baseUrl}/js/jp-chat-widget.js?v=20261111_navy" data-endpoint="http://localhost:3001/api/widget/chat"></script>
</body>
</html>
