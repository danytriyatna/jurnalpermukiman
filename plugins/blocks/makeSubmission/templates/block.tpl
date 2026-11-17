{**
 * plugins/blocks/makeSubmission/templates/block.tpl
 *
 * Common site sidebar menu -- "Make a Submission" / "Register Now" block
 * matching Claude Artifact pill button with gold checkmark icon.
 *}
<div class="pkp_block block_make_submission">
	<div class="content">
		<a class="jp_art_register_pill_btn" href="{url router=$smarty.const.ROUTE_PAGE page="user" op="register"}">
			<span class="jp_art_reg_label">REGISTER NOW</span>
			<span class="jp_art_reg_icon_box">
				<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5"></path></svg>
			</span>
		</a>
	</div>
</div>
