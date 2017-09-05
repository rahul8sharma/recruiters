# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
assets = Rails.application.config.assets
assets.paths << "#{Rails.root}/app/assets/files"
assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
assets.precompile += %w(toolkit/main-layout.css)
assets.precompile += %w(admin.css favicon.ico)
assets.precompile += %w(application.js jquery.js jquery_ujs.js admin.js reports.js norms.js functional_traits.js styles.js ajax.js edit_company.js common.js global_configurations/fallback_strategy.js shared/leadsquared.js add_users.js add_traits.js pie.min.js plotPie.js)
assets.precompile += %w(shared/select_template.js)
assets.precompile += %w(highcharts-custom.js trr-pie.js template.js template_variable.js report_configurations.js jstree.css)
assets.precompile += %w(competencies_management.js show_report_configurations.js)
assets.precompile += %w(shared.css jquery-ui/jquery.datetimepicker.css)
assets.precompile += %w(reports_html.css reports_pdf.css group_report_html.css group_report_pdf.css oac_report_html.css oac_report_pdf.css mrf_report_pdf.css)
assets.precompile += %w(jq/reports_html.css jq/reports_pdf.css)
assets.precompile += %w(users.css)
assets.precompile += %w(tests.css companies.css mrf.css oac.css)
assets.precompile += %w(help.css)
assets.precompile += %w(competencies.js benchmarks.js sign_up.js)
assets.precompile += %w(users_bulk_upload.csv)
assets.precompile += %w(shared/reports/training_requirements/h_graph.css)
assets.precompile += %w(shared/reports/training_requirements/factor_scores.css)
assets.precompile += %w(training_requirements_report.css)
assets.precompile += %w(shared/reports/benchmarks/factor_benchmark.css)
assets.precompile += %w(walk_ins.css walk_ins.js training_requirements.css feedback.css training_requirements_report_pdf.css)
assets.precompile += %w(engagement.css engagement_reports_html.css)
assets.precompile += %w(engagement/elements.js exit/traits.js)
assets.precompile += %w(form_builder/defined_forms.js)
assets.precompile += %w(report_generator.js mrf/order_enable_items.js)
assets.precompile += %w(exit/pie.js exit_reports_html.css)
assets.precompile += %w(compact_reports/reports_pdf.css)
assets.precompile += %w(jq.css)
assets.precompile += %w(mrf/add_users.js set_report_configration.js)
assets.precompile += %w(walkins/email_settings.js)
assets.precompile += %w(jquery-ui/jquery.comiseo.daterangepicker.css)
assets.precompile += %w(suitability/reports.js suitability/assessment.js jquery-ui/jquery.comiseo.daterangepicker.min)
assets.precompile += %w(jquery-ui/jquery-ui.css)
assets.precompile += %w(mrf/walkins/email_settings.js mrf/group_report_pie.js)
assets.precompile += %w(oac/set_weightage_oac.js oac/add_users.js oac/tools/integration_configuration.js)
assets.precompile += %w(trumbowyg.js)
assets.precompile += %w(trumbowyg.css)
assets.precompile += %w(shared/date_time_picker.js)
assets.precompile += %w(shared/export_popup.js select2.min.css)
assets.precompile += %w(jquery-ui/jquery-ui.js jquery-ui/jquery.datetimepicker.full.min.js)
assets.precompile += %w(select_company.js)
assets.precompile += %w(feedback_report/html.css psychometric_report/html.css psychometric_report/pdf.css)
assets.precompile += %w(training_requirements_report/html.css)
