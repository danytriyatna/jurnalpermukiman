{**
 * templates/submission/form/step2.tpl
 *
 * Step 2 of author submission with automated MQC Assistant gatekeeper.
 *}

<script type="text/javascript">
	$(function() {ldelim}
		$('#submitStep2Form').pkpHandler('$.pkp.pages.submission.SubmissionStep2FormHandler');
	{rdelim});
</script>

<form class="pkp_form" id="submitStep2Form" method="post" action="{url op="saveStep" path=$submitStep}" enctype="multipart/form-data" onsubmit="$.pkp.pages.submission.SubmissionStep2FormHandler.prototype.checkSubmit(event)">
	{csrf}
	<input type="hidden" name="submissionId" value="{$submissionId|escape}" />
	{include file="controllers/notification/inPlaceNotification.tpl" notificationId="submitStep2FormNotification"}

	<div id="submission-files-container">
		<submission-files-list-panel v-bind="components.submissionFiles" @set="set"></submission-files-list-panel>
		<script type="text/javascript">
			pkp.registry.init('submission-files-container', 'Container', {$state|json_encode});
		</script>
	</div>

	<!-- MQC ASSISTANT AUTOMATED SCREENING GATEKEEPER -->
	<div id="mqc-gatekeeper-box" style="margin: 24px 0; padding: 20px; background: #f8fafc; border: 2px solid #cbd5e1; border-radius: 10px; font-family: inherit;">
		<div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #0b2545; padding-bottom: 12px; margin-bottom: 16px;">
			<div style="display: flex; align-items: center; gap: 10px;">
				<span style="font-size: 24px;">🛡️</span>
				<div>
					<h3 style="margin: 0; font-size: 16px; color: #0b2545; font-weight: 700;">Verifikasi Standar Format Naskah (MQC Assistant)</h3>
					<p style="margin: 2px 0 0; font-size: 12px; color: #64748b;">Standar Mutu Template Jurnal Permukiman (Kementerian Pekerjaan Umum)</p>
				</div>
			</div>
			<a href="http://localhost:3000" target="_blank" style="font-size: 12px; color: #134074; text-decoration: underline; font-weight: 600;">Buka Portal MQC &rarr;</a>
		</div>

		<div id="mqc-upload-dropzone" style="background: #ffffff; border: 2px dashed #94a3b8; border-radius: 8px; padding: 18px; text-align: center; margin-bottom: 14px;">
			<p style="margin: 0 0 8px; font-size: 13px; color: #334155; font-weight: 600;">
				Pilih berkas Word (.docx) naskah Anda untuk verifikasi otomatis format sebelum melanjutkan:
			</p>
			<input type="file" id="mqc-file-input" accept=".docx" style="display: inline-block; font-size: 13px; color: #475569;" />
			<button type="button" id="mqc-check-btn" style="margin-left: 10px; padding: 7px 18px; background: #0b2545; color: #ffffff; border: none; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">
				Verifikasi Format Sekarang
			</button>
		</div>

		<div id="mqc-result-box" style="display: none; padding: 16px; border-radius: 8px; font-size: 13px; line-height: 1.5;"></div>
	</div>

	<script type="text/javascript">
		(function() {
			var checkBtn = document.getElementById('mqc-check-btn');
			var fileInput = document.getElementById('mqc-file-input');
			var resultBox = document.getElementById('mqc-result-box');
			var submitBtn = document.querySelector('#step2Buttons button[type="submit"]') || document.querySelector('#step2Buttons input[type="submit"]');

			// Kunci tombol submit sebelum ada bukti lolos MQC
			if (submitBtn) {
				submitBtn.disabled = true;
				submitBtn.style.opacity = '0.4';
				submitBtn.title = 'Harap verifikasi format naskah Anda pada kotak MQC di atas terlebih dahulu.';
			}

			checkBtn.addEventListener('click', async function() {
				if (!fileInput.files || fileInput.files.length === 0) {
					alert('Silakan pilih berkas naskah (.docx) terlebih dahulu.');
					return;
				}

				var file = fileInput.files[0];
				if (!file.name.toLowerCase().endsWith('.docx')) {
					alert('Berkas harus berformat Microsoft Word (.docx).');
					return;
				}

				checkBtn.disabled = true;
				checkBtn.textContent = 'Memeriksa 25+ Aturan...';
				resultBox.style.display = 'block';
				resultBox.style.background = '#eff6ff';
				resultBox.style.border = '1px solid #93c5fd';
				resultBox.style.color = '#1e40af';
				resultBox.innerHTML = '⏳ <strong>Sedang memindai format naskah...</strong> Memeriksa margin, heading, tabel, font, dan kepatuhan abstrak...';

				var formData = new FormData();
				formData.append('file', file);

				try {
					var res = await fetch('http://localhost:3000/api/check-submission', {
						method: 'POST',
						body: formData
					});

					var data = await res.json();
					if (!res.ok || !data.success) {
						throw new Error(data.error || 'Gagal memproses naskah di server MQC');
					}

					if (data.passed) {
						resultBox.style.background = '#f0fdf4';
						resultBox.style.border = '1px solid #86efac';
						resultBox.style.color = '#166534';
						resultBox.innerHTML = 
							'<div style="display:flex;align-items:center;gap:8px;font-weight:700;font-size:15px;margin-bottom:6px;">' +
								'<span>✅</span> <span>Lolos Standar Mutu Format MQC (Skor: ' + data.score + '/100)</span>' +
							'</div>' +
							'<p style="margin:0;">Naskah Anda telah memenuhi standar format resmi Jurnal Permukiman. Silakan klik tombol <strong>"Save and continue"</strong> di bawah untuk melanjutkan pengisian metadata.</p>';
						
						if (submitBtn) {
							submitBtn.disabled = false;
							submitBtn.style.opacity = '1';
							submitBtn.title = '';
						}
					} else {
						resultBox.style.background = '#fef2f2';
						resultBox.style.border = '1px solid #fca5a5';
						resultBox.style.color = '#991b1b';
						
						var issuesHtml = '<ul style="margin:8px 0 12px 20px;padding:0;">';
						var errorItems = data.errors || [];
						for (var i = 0; i < Math.min(errorItems.length, 5); i++) {
							var err = errorItems[i];
							issuesHtml += '<li style="margin-bottom:4px;"><strong>' + (err.ruleId || 'Format') + ':</strong> ' + (err.suggestedFix || err.expectedValue) + '</li>';
						}
						if (errorItems.length > 5) {
							issuesHtml += '<li><em>...dan ' + (errorItems.length - 5) + ' catatan lainnya.</em></li>';
						}
						issuesHtml += '</ul>';

						resultBox.innerHTML = 
							'<div style="display:flex;align-items:center;gap:8px;font-weight:700;font-size:15px;margin-bottom:6px;">' +
								'<span>❌</span> <span>Belum Memenuhi Standar Format (Skor: ' + data.score + '/100 — ' + (data.summary ? data.summary.errorCount : 0) + ' Pelanggaran Kritis)</span>' +
							'</div>' +
							'<p style="margin:0 0 6px;">Naskah belum dapat diproses ke tahap metadata karena masih terdapat pelanggaran format template berikut:</p>' +
							issuesHtml +
							'<div style="margin-top:10px;">' +
								'<a href="http://localhost:3000" target="_blank" style="display:inline-block;padding:8px 16px;background:#991b1b;color:#ffffff;text-decoration:none;font-weight:600;border-radius:6px;font-size:12px;">' +
									'🛠️ Buka Aplikasi MQC Assistant untuk Panduan Perbaikan Interaktif &rarr;' +
								'</a>' +
							'</div>';

						if (submitBtn) {
							submitBtn.disabled = true;
							submitBtn.style.opacity = '0.4';
							submitBtn.title = 'Perbaiki format naskah terlebih dahulu hingga skor MQC mencapai minimal 80%.';
						}
					}
				} catch (err) {
					resultBox.style.background = '#fffbeb';
					resultBox.style.border = '1px solid #fde68a';
					resultBox.style.color = '#92400e';
					resultBox.innerHTML = '⚠️ <strong>Peringatan:</strong> ' + err.message + '. Pastikan aplikasi MQC Assistant aktif di http://localhost:3000.';
				} finally {
					checkBtn.disabled = false;
					checkBtn.textContent = 'Verifikasi Format Sekarang';
				}
			});
		})();
	</script>

	{fbvFormButtons id="step2Buttons" submitText="common.saveAndContinue"}
</form>
