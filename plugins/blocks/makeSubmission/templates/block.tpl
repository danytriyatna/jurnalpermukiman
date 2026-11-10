{**
 * plugins/blocks/makeSubmission/templates/block.tpl
 *
 * Copyright (c) 2014-2020 Simon Fraser University
 * Copyright (c) 2003-2020 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * Common site sidebar menu -- "Make a Submission" block.
 *}
<div class="pkp_block block_make_submission">
	<div class="content">
		<a class="block_make_submission_link make_submission_cta_btn" href="{url router=$smarty.const.ROUTE_PAGE page="about" op="submissions"}" aria-label="{translate|escape key="plugins.block.makeSubmission.linkLabel"}">
			<span class="ms_title_row">
				<i class="fa fa-paper-plane" aria-hidden="true"></i>
				<span>MAKE A SUBMISSION</span>
			</span>
			<span class="ms_subtitle">Submit your research manuscript online</span>
		</a>
	</div>
</div>
