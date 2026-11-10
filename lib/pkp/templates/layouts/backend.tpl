{**
 * lib/pkp/templates/layouts/backend.tpl
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * Common site header.
 *}
<!DOCTYPE html>
<html lang="{$currentLocale|replace:"_":"-"}" xml:lang="{$currentLocale|replace:"_":"-"}">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset={$defaultCharset|escape}" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>{title|strip_tags value=$pageTitle}</title>
	{load_header context="backend"}
	{load_stylesheet context="backend"}
	{load_script context="backend"}
{literal}
<style id="puskim-backend-unified">
  /* =====================================================================
     PUSKIM BACKEND WORKSPACE UNIFICATION (MERAH BATA #C13D0D + CLEAN UI)
     ===================================================================== */
  html:has(#app), body:has(#app) {
    background: #F3F4F6 !important;
    background-image: none !important;
    color: #1E293B !important;
  }

  #app, .app {
    background: #F3F4F6 !important;
  }

  .app__body {
    background: #F3F4F6 !important;
  }

  /* SIDEBAR KIRI: WARM SURFACE (STRUKTUR TETAP, WARNA & KONTRAS SELARAS) */
  .app__nav {
    background: #FAF8F6 !important;
    border-right: 1px solid #E5DCD5 !important;
    box-shadow: 2px 0 10px rgba(15, 23, 42, 0.03) !important;
    flex: 0 0 248px !important;
    width: 248px !important;
    padding: 1.25rem 0.9rem !important;
  }

  .app__navGroup {
    margin-top: 1.15rem !important;
    margin-bottom: 0.75rem !important;
    padding-top: 0.9rem !important;
    border-top: 1px solid #EDE5DF !important;
  }

  .app__navGroup .app__navItem--hasSubmenu {
    color: #94A3B8 !important;
    font-weight: 800 !important;
    font-size: 10.5px !important;
    text-transform: uppercase !important;
    letter-spacing: 0.09em !important;
    padding: 0 0.75rem 0.45rem !important;
    margin: 0 !important;
  }

  .app__navItem[data-menu-key] {
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
    padding: 9px 12px !important;
    margin-bottom: 3px !important;
    border-radius: 8px !important;
    font-size: 13.5px !important;
    font-weight: 600 !important;
    color: #334155 !important;
    text-decoration: none !important;
    transition: all 0.16s ease !important;
  }

  .app__navItem[data-menu-key]::before {
    font-family: FontAwesome !important;
    font-size: 13.5px !important;
    width: 16px !important;
    text-align: center !important;
    color: #94A3B8 !important;
    transition: color 0.16s ease !important;
    content: "\f111";
  }

  .app__navItem[data-menu-key="submissions"]::before { content: "\f0ea" !important; }
  .app__navItem[data-menu-key="submit"]::before { content: "\f1d8" !important; }
  .app__navItem[data-menu-key="issues"]::before { content: "\f02d" !important; }
  .app__navItem[data-menu-key="announcements"]::before { content: "\f0a1" !important; }
  .app__navItem[data-menu-key="payments"]::before { content: "\f0d6" !important; }
  .app__navItem[data-menu-key="context"]::before { content: "\f19c" !important; }
  .app__navItem[data-menu-key="website"]::before { content: "\f0ac" !important; }
  .app__navItem[data-menu-key="workflow"]::before { content: "\f085" !important; }
  .app__navItem[data-menu-key="distribution"]::before { content: "\f1e0" !important; }
  .app__navItem[data-menu-key="access"]::before { content: "\f0c0" !important; }
  .app__navItem[data-menu-key="publications"]::before { content: "\f02e" !important; }
  .app__navItem[data-menu-key="editorial"]::before { content: "\f080" !important; }
  .app__navItem[data-menu-key="users"]::before { content: "\f007" !important; }
  .app__navItem[data-menu-key="reports"]::before { content: "\f0ce" !important; }
  .app__navItem[data-menu-key="tools"]::before { content: "\f0ad" !important; }
  .app__navItem[data-menu-key="admin"]::before { content: "\f013" !important; }

  .app__navItem[data-menu-key]:hover {
    background: #FDF4F0 !important;
    color: #C13D0D !important;
    transform: translateX(3px) !important;
  }
  .app__navItem[data-menu-key]:hover::before {
    color: #C13D0D !important;
  }

  .app__navItem--isCurrent,
  .app__navItem--isCurrent[data-menu-key] {
    background: linear-gradient(135deg, #C13D0D 0%, #A0320A 100%) !important;
    color: #FFFFFF !important;
    font-weight: 700 !important;
    box-shadow: 0 4px 12px rgba(193, 61, 13, 0.28) !important;
    transform: none !important;
  }
  .app__navItem--isCurrent[data-menu-key]::before,
  .app__navItem--isCurrent[data-menu-key]:hover::before {
    color: #FFFFFF !important;
  }
  .app__navItem--isCurrent:hover,
  .app__navItem--isCurrent[data-menu-key]:hover {
    background: linear-gradient(135deg, #A0320A 0%, #862908 100%) !important;
    color: #FFFFFF !important;
  }

  /* WORKSPACE MAIN & PAGE HEADING */
  .app__main {
    background: #F3F4F6 !important;
    padding: 1.75rem 2.25rem !important;
  }

  .app__pageHeading {
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
    font-size: 20px !important;
    font-weight: 800 !important;
    color: #0F172A !important;
    margin: 0 0 18px 0 !important;
    letter-spacing: -0.01em !important;
  }
  .app__pageHeading::before {
    content: "" !important;
    display: inline-block !important;
    width: 6px !important;
    height: 22px !important;
    background: #C13D0D !important;
    border-radius: 9999px !important;
  }

  /* TABS ANTREAN MODERN (MY QUEUE, UNASSIGNED, ALL ACTIVE, ARCHIVES) */
  .pkpTabs__buttons {
    border-bottom: 2px solid #E2E8F0 !important;
    padding: 0 !important;
    margin-bottom: 18px !important;
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    gap: 6px !important;
  }

  .pkpTabs__button {
    background: transparent !important;
    border: none !important;
    border-bottom: 3px solid transparent !important;
    border-radius: 8px 8px 0 0 !important;
    padding: 10px 16px !important;
    margin: 0 0 -2px 0 !important;
    top: 0 !important;
    color: #64748B !important;
    font-size: 13.5px !important;
    font-weight: 600 !important;
    transition: all 0.16s ease !important;
  }
  .pkpTabs__button:before,
  .pkpTabs__button:after {
    display: none !important;
    content: none !important;
  }
  .pkpTabs__button:hover {
    background: rgba(193, 61, 13, 0.06) !important;
    color: #C13D0D !important;
  }
  .pkpTabs__button[aria-selected="true"] {
    background: #FFFFFF !important;
    color: #C13D0D !important;
    font-weight: 800 !important;
    border-bottom: 3px solid #C13D0D !important;
    box-shadow: 0 -2px 8px rgba(15, 23, 42, 0.04) !important;
  }
  .pkpTabs__button .pkpBadge {
    background: #E2E8F0 !important;
    color: #475569 !important;
    border: none !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    padding: 2px 8px !important;
    margin-left: 6px !important;
    border-radius: 9999px !important;
  }
  .pkpTabs__button[aria-selected="true"] .pkpBadge {
    background: #FDF4F0 !important;
    color: #C13D0D !important;
    border: 1px solid #F4D4C9 !important;
  }

  /* LIST PANEL SUBMISSIONS / ISSUES / ANNOUNCEMENTS */
  .listPanel {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 14px !important;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04), 0 1px 2px rgba(15, 23, 42, 0.02) !important;
    overflow: hidden !important;
  }
  .listPanel__header {
    background: #F8FAFC !important;
    border-bottom: 1px solid #E2E8F0 !important;
    padding: 14px 20px !important;
  }
  .listPanel__header .pkpHeader__title,
  .listPanel__header .pkpHeader__title > h2 {
    font-size: 15px !important;
    font-weight: 800 !important;
    color: #0F172A !important;
  }
  .listPanel__body {
    border-top: none !important;
  }
  .listPanel__items {
    background: #FFFFFF !important;
  }
  .listPanel__item {
    padding: 16px 20px !important;
    border-bottom: 1px solid #F1F5F9 !important;
    transition: background 0.15s ease !important;
  }
  .listPanel__item:last-child {
    border-bottom: none !important;
  }
  .listPanel__item:hover {
    background: #FDF9F7 !important;
  }
  .listPanel__itemIdentity--submission {
    padding-left: 3.75rem !important;
  }
  .listPanel__item--submission__id {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    color: #C13D0D !important;
    background: #FDF4F0 !important;
    border: 1px solid #F4D4C9 !important;
    padding: 2px 8px !important;
    border-radius: 6px !important;
    text-align: center !important;
    width: auto !important;
    min-width: 44px !important;
  }
  .listPanel__item--submission__author {
    font-weight: 700 !important;
    color: #0F172A !important;
    font-size: 13.5px !important;
  }
  .listPanel__item--submission__title {
    color: #475569 !important;
    font-size: 13px !important;
    margin-top: 2px !important;
  }

  /* SEARCH INPUT MODERN */
  .pkpSearch .pkpSearch__input {
    border-radius: 8px !important;
    border: 1px solid #CBD5E1 !important;
    background: #FFFFFF !important;
    font-size: 13px !important;
    color: #1E293B !important;
    transition: all 0.15s ease !important;
  }
  .pkpSearch .pkpSearch__input:focus {
    border-color: #C13D0D !important;
    box-shadow: 0 0 0 3px rgba(193, 61, 13, 0.12) !important;
    outline: none !important;
  }

  /* BUTTONS & PRIMARY CTA MERAH BATA */
  .pkpButton {
    border: 1px solid #CBD5E1 !important;
    background: #FFFFFF !important;
    color: #334155 !important;
    border-radius: 8px !important;
    font-weight: 600 !important;
    font-size: 12.5px !important;
    transition: all 0.15s ease !important;
  }
  .pkpButton:hover {
    border-color: #C13D0D !important;
    color: #C13D0D !important;
    background: #FDF4F0 !important;
  }

  .pkpButton--primary,
  button.pkpButton--primary,
  .pkpButton--isPrimary,
  .pkp_button_primary,
  .listPanel__header .pkpHeader__actions a[href*="submission/wizard"],
  .listPanel--submissions .pkpHeader__actions a.pkpButton {
    background: linear-gradient(135deg, #C13D0D 0%, #A0320A 100%) !important;
    border: 1px solid #A0320A !important;
    color: #FFFFFF !important;
    border-radius: 8px !important;
    font-weight: 700 !important;
    font-size: 12.5px !important;
    box-shadow: 0 2px 8px rgba(193, 61, 13, 0.25) !important;
  }
  .pkpButton--primary:hover,
  button.pkpButton--primary:hover,
  .pkpButton--isPrimary:hover,
  .pkp_button_primary:hover,
  .listPanel__header .pkpHeader__actions a[href*="submission/wizard"]:hover,
  .listPanel--submissions .pkpHeader__actions a.pkpButton:hover {
    background: linear-gradient(135deg, #A0320A 0%, #862908 100%) !important;
    border-color: #862908 !important;
    color: #FFFFFF !important;
    box-shadow: 0 4px 12px rgba(193, 61, 13, 0.35) !important;
    transform: translateY(-1px) !important;
  }

  /* STAGE BADGE & FORM ACCENT */
  .pkpBadge--isPrimary {
    background: #C13D0D !important;
    border-color: #C13D0D !important;
    color: #FFFFFF !important;
  }
  .pkpBadge {
    font-weight: 700 !important;
    font-size: 11.5px !important;
    border-radius: 9999px !important;
  }

  /* GLOBAL WORKFLOW / LINK / TAB OVERRIDES (UNIFY BIRU PU -> MERAH BATA) */
  .-linkButton,
  a.pkpLink,
  .pkpWorkflow__identificationId,
  .pkpWorkflow__identificationAuthor,
  .app__breadcrumbs a:hover,
  .pkpWorkflow .pkpTabs__button[aria-selected="true"],
  .pkp_controllers_grid .actions a,
  .pkp_controllers_grid .header .actions a,
  .pkp_controllers_grid .download_all_files {
    color: #C13D0D !important;
  }
  .pkpWorkflow .pkpTabs__button[aria-selected="true"] {
    background: #FDF4F0 !important;
    border-bottom: 3px solid #C13D0D !important;
  }
  .pkpWorkflow__sidebar button.pkpButton--primary {
    background: linear-gradient(135deg, #C13D0D 0%, #A0320A 100%) !important;
    border-color: #A0320A !important;
    color: #FFFFFF !important;
    box-shadow: 0 2px 8px rgba(193, 61, 13, 0.28) !important;
  }
  .pkpWorkflow__sidebar button.pkpButton:not(.pkpButton--primary):not(.pkpButton--warnable) {
    color: #C13D0D !important;
    border-color: #F4D4C9 !important;
  }
  .pkpWorkflow__sidebar button.pkpButton:not(.pkpButton--primary):not(.pkpButton--warnable):hover {
    background: #FDF4F0 !important;
    border-color: #C13D0D !important;
  }
  .pkp_controllers_grid .actions a:hover,
  .pkp_controllers_grid .header .actions a:hover,
  .pkp_controllers_grid .download_all_files:hover {
    background: #FDF4F0 !important;
    border-color: #C13D0D !important;
  }

  /* =====================================================================
     FORM, SIDE-TABS & MODAL REDESIGN (STRUKTUR TETAP, WARNA & SURFACE SELARAS)
     ===================================================================== */
  /* Side Tabs di Halaman Settings (Masthead, Contact, Appearance, dll) */
  .pkpTabs--side .pkpTabs__buttons {
    background: #FAF8F6 !important;
    border: 1px solid #E5DCD5 !important;
    border-radius: 12px !important;
    padding: 8px !important;
    box-shadow: 0 1px 3px rgba(15, 23, 42, 0.03) !important;
  }
  .pkpTabs--side .pkpTabs__button {
    border: none !important;
    border-left: 3px solid transparent !important;
    border-radius: 8px !important;
    margin: 2px 0 !important;
    padding: 9px 14px !important;
    color: #475569 !important;
    text-align: left !important;
  }
  .pkpTabs--side .pkpTabs__button:hover {
    background: #FDF4F0 !important;
    color: #C13D0D !important;
  }
  .pkpTabs--side .pkpTabs__button[aria-selected="true"] {
    background: #FDF4F0 !important;
    color: #C13D0D !important;
    font-weight: 800 !important;
    border-bottom: none !important;
    border-left: 3px solid #C13D0D !important;
    box-shadow: none !important;
  }

  /* Form Container & Group Surfaces (Tanpa Merubah Struktur Kolom) */
  .pkpForm {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 14px !important;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04) !important;
    overflow: hidden !important;
  }
  .pkpFormPages {
    background: #FFFFFF !important;
  }
  .pkpFormGroup {
    border-color: #F1F5F9 !important;
  }
  .pkpFormGroup__legend {
    color: #0F172A !important;
    font-weight: 800 !important;
  }
  .pkpFormGroup__description {
    color: #64748B !important;
  }
  .pkpFormPage__footer {
    background: #F8FAFC !important;
    border-top: 1px solid #E2E8F0 !important;
  }

  /* Language Tabs inside Form */
  .pkpFormLocales {
    background: #FAF8F6 !important;
    border-bottom: 1px solid #E5DCD5 !important;
  }
  .pkpFormLocales__locale {
    color: #64748B !important;
    font-weight: 600 !important;
  }
  .pkpFormLocales__locale:hover,
  .pkpFormLocales__locale--isActive {
    color: #C13D0D !important;
    border-color: #C13D0D !important;
    font-weight: 700 !important;
  }

  /* Form Inputs, Selects & Textareas (Vue & Legacy .pkp_form) */
  .pkpFormField--text__input,
  .pkpFormField--textarea__input,
  .pkpFormField--select__input,
  .pkpFormField--autosuggest__input,
  .pkp_form input[type="text"],
  .pkp_form input[type="email"],
  .pkp_form input[type="url"],
  .pkp_form input[type="password"],
  .pkp_form input[type="number"],
  .pkp_form select,
  .pkp_form textarea {
    background: #F8FAFC !important;
    border: 1px solid #CBD5E1 !important;
    border-radius: 8px !important;
    color: #1E293B !important;
    transition: all 0.15s ease !important;
  }
  .pkpFormField--text__input:focus,
  .pkpFormField--textarea__input:focus,
  .pkpFormField--select__input:focus,
  .pkpFormField--autosuggest__input:focus,
  .pkp_form input[type="text"]:focus,
  .pkp_form input[type="email"]:focus,
  .pkp_form input[type="url"]:focus,
  .pkp_form input[type="password"]:focus,
  .pkp_form input[type="number"]:focus,
  .pkp_form select:focus,
  .pkp_form textarea:focus {
    background: #FFFFFF !important;
    border-color: #C13D0D !important;
    box-shadow: 0 0 0 3px rgba(193, 61, 13, 0.12) !important;
    outline: none !important;
  }
  #app input[type="checkbox"],
  #app input[type="radio"],
  .pkp_modal_panel input[type="checkbox"],
  .pkp_modal_panel input[type="radio"] {
    accent-color: #C13D0D !important;
  }

  /* MODAL & DIALOG SYSTEM (LEGACY PKP MODAL + VUE MODAL + JQUERY UI DIALOG) */
  .pkp_modal,
  .ui-widget-overlay,
  .v--modal-overlay {
    background: rgba(15, 23, 42, 0.6) !important;
    backdrop-filter: blur(4px) !important;
    -webkit-backdrop-filter: blur(4px) !important;
  }

  .pkp_modal_panel,
  .ui-dialog,
  .v--modal-box.v--modal {
    background: #FFFFFF !important;
    border-radius: 14px !important;
    border: 1px solid #E2E8F0 !important;
    border-top: 4px solid #C13D0D !important;
    box-shadow: 0 24px 48px -12px rgba(15, 23, 42, 0.35) !important;
    overflow: hidden !important;
  }

  .pkp_modal_panel .header,
  .ui-dialog-titlebar {
    background: #FDF9F7 !important;
    border-bottom: 1px solid #F4D4C9 !important;
    color: #0F172A !important;
    font-weight: 800 !important;
    padding: 1rem 1.5rem !important;
  }

  .pkp_modal_panel .close,
  .ui-dialog-titlebar-close {
    color: #64748B !important;
    border-radius: 8px !important;
    transition: all 0.15s ease !important;
  }
  .pkp_modal_panel .close:hover,
  .ui-dialog-titlebar-close:hover {
    background: #FDF4F0 !important;
    color: #C13D0D !important;
  }

  .pkp_modal_panel .footer,
  .pkp_modal_panel .formButtons {
    background: #F8FAFC !important;
    border-top: 1px solid #E2E8F0 !important;
  }
  .pkp_modal_panel .pkp_button_primary,
  .pkp_modal_panel button.submitFormButton {
    background: linear-gradient(135deg, #C13D0D 0%, #A0320A 100%) !important;
    border: 1px solid #A0320A !important;
    color: #FFFFFF !important;
    border-radius: 8px !important;
    box-shadow: 0 2px 8px rgba(193, 61, 13, 0.28) !important;
  }
  .pkp_modal_panel .pkp_button_primary:hover,
  .pkp_modal_panel button.submitFormButton:hover {
    background: linear-gradient(135deg, #A0320A 0%, #862908 100%) !important;
  }

  /* =====================================================================
     ISSUES, TOOLS (.pkp_controllers_tab), STATISTICS (.pkpStats/.pkpTable),
     & ADMINISTRATION (.app__contentPanel)
     ===================================================================== */
  /* Legacy jQuery UI Tabs (Issues, Tools, Plugins, Modals) */
  .pkp_controllers_tab .ui-tabs-nav {
    background: transparent !important;
    border-bottom: 2px solid #E2E8F0 !important;
    padding: 0 !important;
    margin-bottom: 18px !important;
  }
  .pkp_controllers_tab .ui-tabs-nav li a {
    color: #64748B !important;
    font-weight: 600 !important;
    border-radius: 8px 8px 0 0 !important;
    transition: all 0.15s ease !important;
  }
  .pkp_controllers_tab .ui-tabs-nav li a:before {
    background: transparent !important;
  }
  .pkp_controllers_tab .ui-tabs-nav li a:hover {
    background: rgba(193, 61, 13, 0.06) !important;
    color: #C13D0D !important;
  }
  .pkp_controllers_tab .ui-tabs-nav .ui-state-active {
    background: #FFFFFF !important;
    border-bottom: 3px solid #C13D0D !important;
    margin-bottom: -2px !important;
  }
  .pkp_controllers_tab .ui-tabs-nav .ui-state-active a {
    color: #C13D0D !important;
    font-weight: 800 !important;
  }
  .pkp_controllers_tab .ui-tabs-nav .ui-state-active a:before,
  .pkp_controllers_tab .ui-tabs-nav li a:hover:before,
  .pkp_controllers_tab .ui-tabs-nav li a:focus:before {
    background: #C13D0D !important;
  }

  /* Statistics (Articles, Editorial Activity, Users, Reports) */
  .pkpStats {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 14px !important;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04) !important;
    padding: 20px 24px !important;
  }
  .pkpStats__graph {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 12px !important;
    padding: 16px !important;
  }
  .pkpTable {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 12px !important;
    overflow: hidden !important;
  }
  .pkpTable caption {
    background: #F8FAFC !important;
    border-bottom: 1px solid #E2E8F0 !important;
    color: #0F172A !important;
    font-weight: 700 !important;
  }
  .pkpTable thead th {
    background: #F8FAFC !important;
    color: #334155 !important;
    border-bottom: 1px solid #E2E8F0 !important;
  }
  .pkpTable th:focus {
    box-shadow: inset 0 0 0 2px #C13D0D !important;
  }
  .pkpTable tr:hover td {
    background: #FDF9F7 !important;
  }
  .pkpStats__itemLink,
  .pkpTable a {
    color: #C13D0D !important;
    font-weight: 600 !important;
  }
  .pkpPagination {
    background: #F8FAFC !important;
    border: 1px solid #E2E8F0 !important;
    border-top: none !important;
    border-radius: 0 0 12px 12px !important;
  }

  /* Administration & Content Panels */
  .app__contentPanel {
    background: #FFFFFF !important;
    border: 1px solid #E2E8F0 !important;
    border-radius: 14px !important;
    box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04) !important;
    padding: 24px 28px !important;
  }
  .app__contentPanel h2 {
    color: #0F172A !important;
    font-weight: 800 !important;
    border-bottom: 2px solid rgba(193, 61, 13, 0.18) !important;
    padding-bottom: 8px !important;
    margin-bottom: 12px !important;
  }
  .app__contentPanel li {
    padding: 6px 0 !important;
    border-bottom: 1px solid #F1F5F9 !important;
  }
  .app__contentPanel li:last-child {
    border-bottom: none !important;
  }
  .app__contentPanel a,
  .app__main .pkp_controllers_grid td a:not(.pkp_button):not(.pkpButton) {
    color: #C13D0D !important;
    font-weight: 600 !important;
    text-decoration: none !important;
  }
  .app__contentPanel a:hover,
  .app__main .pkp_controllers_grid td a:not(.pkp_button):not(.pkpButton):hover {
    text-decoration: underline !important;
    color: #A0320A !important;
  }
</style>
{/literal}
</head>
<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

	<script type="text/javascript">
		// Initialise JS handler.
		$(function() {ldelim}
			$('body').pkpHandler(
				'$.pkp.controllers.SiteHandler',
				{ldelim}
					{include file="controllers/notification/notificationOptions.tpl"}
				{rdelim});

			// Cegah kolom tabel grid membungkus jadi 2 baris (Single Line Metadata)
			function enforceSingleLineMetadata() {
				$('.pkp_controllers_grid td .label br').replaceWith(' <span class="grid_line_sep" style="color:#94a3b8; font-weight:normal; margin:0 6px;">&bull;</span> ');
				$('.pkp_controllers_grid td.column-from br').replaceWith(' <span class="grid_line_sep" style="color:#94a3b8; font-weight:normal; margin:0 6px;">&bull;</span> ');
				$('.pkp_controllers_grid td.column-date br').replaceWith(' ');
				$('.pkp_controllers_grid td[class*="date"] br').replaceWith(' ');
			}
			enforceSingleLineMetadata();
			$(document).ajaxComplete(function() {ldelim}
				enforceSingleLineMetadata();
			{rdelim});
		{rdelim});
	</script>

	<div id="app" class="app {if $isLoggedInAs} app--isLoggedInAs{/if}">
		<header class="app__header" role="banner">
			{if $availableContexts}
				<dropdown class="app__headerAction app__contexts" v-cloak>
					<template slot="button">
						<icon icon="sitemap"></icon>
						<span class="-screenReader">{translate key="context.contexts"}</span>
					</template>
					<ul>
						{foreach from=$availableContexts item=$availableContext}
							{if !$currentContext || $availableContext->name !== $currentContext->getLocalizedData('name')}
								<li>
									<a href="{$availableContext->url|escape}" class="pkpDropdown__action">
										{$availableContext->name|escape}
									</a>
								</li>
							{/if}
						{/foreach}
					</ul>
				</dropdown>
			{/if}
			{if $currentContext}
				<a class="app__contextTitle" href="{url page="index"}">
					<div class="app__brandLogo">
						<span class="app__brandLine1">JURNAL</span>
						<span class="app__brandLine2">PERMUKIMAN</span>
					</div>
				</a>
			{elseif $siteTitle}
				<a class="app__contextTitle" href="{$baseUrl}">
					<div class="app__brandLogo">
						<span class="app__brandLine1">JURNAL</span>
						<span class="app__brandLine2">PERMUKIMAN</span>
					</div>
				</a>
			{else}
				<div class="app__contextTitle">
					{translate key="common.software"}
				</div>
			{/if}
			{if $currentUser}
				<div class="app__headerRight">
					<div class="app__headerBadgePU">
						<img src="{$baseUrl}/public/journals/1/kemenpu_pill_clean.png" alt="Kementerian PU" />
					</div>
					<div class="app__headerActions" v-cloak>
					{call_hook name="Template::Layout::Backend::HeaderActions"}
					<div class="app__headerAction app__tasks">
						<button ref="tasksButton" @click="openTasks">
							<icon icon="bell-o"></icon>
							<span class="-screenReader">{translate key="common.tasks"}</span>
							<span v-if="unreadTasksCount" class="app__tasksCount">{{ unreadTasksCount }}</span>
						</button>
					</div>
					<dropdown class="app__headerAction app__userNav">
						<template slot="button">
							<icon icon="user-circle-o"></icon>
							{if $isUserLoggedInAs}
								<icon icon="user-circle" class="app__userNav__isLoggedInAsWarning"></icon>
							{/if}
							<span class="-screenReader">{$currentUser->getData('username')}</span>
						</template>
						<nav aria-label="{translate key="common.navigation.user"}">
							{if $supportedLocales|@count > 1}
								<div class="pkpDropdown__section">
									<div class="app__userNav__changeLocale">Change Language</div>
									<ul>
										{foreach from=$supportedLocales item="locale" key="localeKey"}
											<li>
												<a href="{url router=$smarty.const.ROUTE_PAGE page="user" op="setLocale" path=$localeKey}" class="pkpDropdown__action">
													{if $localeKey == $currentLocale}
														<icon icon="check" :inline="true"></icon>
													{/if}
													{$locale|escape}
												</a>
											</li>
										{/foreach}
									</ul>
								</div>
							{/if}
							{if $isUserLoggedInAs}
								<div class="pkpDropdown__section">
									<div class="app__userNav__loggedInAs">
										{translate key="manager.people.signedInAs" username=$currentUser->getData('username')}
										<a href="{url router=$smarty.const.ROUTE_PAGE page="login" op="signOutAsUser"}" class="app__userNav__logOutAs">{translate key="user.logOutAs" username=$currentUser->getData('username')}</a>.
									</div>
								</div>
							{/if}
							<div class="pkpDropdown__section">
								<ul>
									<li v-if="backToDashboardLink">
										<a :href="backToDashboardLink.url" class="pkpDropdown__action">
											{{ backToDashboardLink.name }}
										</a>
									</li>
									<li>
										<a href="{url router=$smarty.const.ROUTE_PAGE page="user" op="profile"}" class="pkpDropdown__action">
											{translate key="user.profile.editProfile"}
										</a>
									</li>
									<li>
										{if $isUserLoggedInAs}
											<a href="{url router=$smarty.const.ROUTE_PAGE page="login" op="signOutAsUser"}" class="pkpDropdown__action">
												{translate key="user.logOutAs" username=$currentUser->getData('username')}
											</a>
										{else}
											<a href="{url router=$smarty.const.ROUTE_PAGE page="login" op="signOut"}" class="pkpDropdown__action">
												{translate key="user.logOut"}
											</a>
										{/if}
									</li>
								</ul>
							</div>
						</nav>
					</dropdown>
				</div>
				</div>
			{/if}
		</header>

		{* Swap the navigation menu for a back-to-dashboard link when only one item exists *}
		<nav v-if="backToDashboardLink" class="app__returnHeader" aria-label="{translate key="common.navigation.site"}">
			<a class="app__returnHeaderLink" :href="backToDashboardLink.url">
				{{ backToDashboardLabel }}
			</a>
		</nav>

		<div class="app__body">
			{block name="menu"}
				<nav v-if="!!menu && Object.keys(menu).length > 1" class="app__nav" aria-label="{translate key="common.navigation.site"}">
					<ul>
						<li v-for="(menuItem, key) in menu" :key="key" :class="!!menuItem.submenu ? 'app__navGroup' : ''">
							<div v-if="!!menuItem.submenu" class="app__navItem app__navItem--hasSubmenu">
								{{ menuItem.name }}
							</div>
							<a v-else class="app__navItem" :class="menuItem.isCurrent ? 'app__navItem--isCurrent' : ''" :data-menu-key="key" :href="menuItem.url">
								{{ menuItem.name }}
							</a>
							<ul v-if="!!menuItem.submenu">
								<li v-for="(submenuItem, submenuKey) in menuItem.submenu" :key="submenuKey">
									<a class="app__navItem" :class="submenuItem.isCurrent ? 'app__navItem--isCurrent' : ''" :data-menu-key="submenuKey" :href="submenuItem.url">
										{{ submenuItem.name }}
									</a>
								</li>
							</ul>
						</li>
					</ul>
				</nav>
			{/block}

			<main class="app__main">
				<div class="app__page{if $pageWidth} app__page--{$pageWidth}{/if}">
					{block name="breadcrumbs"}
						{if $breadcrumbs}
							<nav class="app__breadcrumbs" role="navigation" aria-label="{translate key="navigation.breadcrumbLabel"}">
								<ol>
									{foreach from=$breadcrumbs item="breadcrumb" name="breadcrumbs"}
										<li>
											{if $smarty.foreach.breadcrumbs.last}
												<span aria-current="page">{$breadcrumb.name|escape}</span>
											{else}
												<a href="{$breadcrumb.url|escape}">
													{$breadcrumb.name|escape}
												</a>
												<span class="app__breadcrumbsSeparator" aria-hidden="true">{translate key="navigation.breadcrumbSeparator"}</span>
											{/if}
										</li>
									{/foreach}
								</ol>
							</nav>
						{/if}
					{/block}

					{block name="page"}{/block}

				</div>
			</main>
		</div>
		<div
			aria-live="polite"
			aria-atomic="true"
			class="app__notifications"
			ref="notifications"
			role="status"
		>
			<transition-group name="app__notification">
				<notification v-for="notification in notifications" :key="notification.key" :type="notification.type" :can-dismiss="true" @dismiss="dismissNotification(notification.key)">
					{{ notification.message }}
				</notification>
			</transition-group>
		</div>
	</div>

	<script type="text/javascript">
		pkp.registry.init('app', {$pageComponent|json_encode}, {$state|json_encode});
	</script>

	<script type="text/javascript">
		// Initialize JS handler
		$(function() {ldelim}
			$('#pkpHelpPanel').pkpHandler(
				'$.pkp.controllers.HelpPanelHandler',
				{ldelim}
					helpUrl: {url|json_encode page="help" escape=false},
					helpLocale: '{$currentLocale|substr:0:2}',
				{rdelim}
			);
		{rdelim});
	</script>
	<div id="pkpHelpPanel" class="pkp_help_panel" tabindex="-1">
		<div class="panel">
			<div class="header">
				<a href="#" class="pkpHomeHelpPanel home">
					{translate key="help.toc"}
				</a>
				<a href="#" class="pkpCloseHelpPanel close">
					{translate key="common.close"}
				</a>
			</div>
			<div class="content">
				{include file="common/loadingContainer.tpl"}
			</div>
			<div class="footer">
				<a href="#" class="pkpPreviousHelpPanel previous">
					{translate key="help.previous"}
				</a>
				<a href="#" class="pkpNextHelpPanel next">
					{translate key="help.next"}
				</a>
			</div>
		</div>
	</div>

</body>
</html>
