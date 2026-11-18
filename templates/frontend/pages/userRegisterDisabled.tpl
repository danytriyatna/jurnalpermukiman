{**
 * templates/frontend/pages/userRegisterDisabled.tpl
 *
 * Manual user registration instructions displayed when self-registration is disabled.
 *}
{include file="frontend/components/header.tpl" pageTitle="user.register"}

<div class="page page_register">
	{include file="frontend/components/breadcrumbs.tpl" currentTitleKey="user.register"}
	<h2>Registration</h2>
	<p>To proceed with registration, please contact the editorial team at <a href="mailto:jurnalpermukiman@pu.go.id">jurnalpermukiman@pu.go.id</a> and provide the following information:</p>
	<p>Given Name:<br>Family Name:<br>Affiliation:<br>Country:<br>Email Address:<br>Preferred Username:<br>Temporary Password: (you may update this after your first login)</p>
	<p>We apologize for the inconvenience and appreciate your understanding. Our team will assist you in completing the registration manually.</p>
	<p>Best regards,<br>Editorial Team<br>Jurnal&nbsp;Permukiman</p>
</div>

{include file="frontend/components/footer.tpl"}
