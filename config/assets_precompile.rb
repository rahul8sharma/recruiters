# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
assets = Rails.application.config.assets
assets.paths << "#{Rails.root}/app/assets/files"
assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
assets.precompile += %w(toolkit/main-layout.css)
assets.precompile += %w(admin.css)
assets.precompile += %w(application.js jquery.js jquery_ujs.js admin.js reports.js norms.js styles.js edit_company.js common.js global_configurations/fallback_strategy.js shared/leadsquared.js add_candidates.js)
assets.precompile += %w(shared.css)
assets.precompile += %w(reports_html.css reports_pdf.css)
assets.precompile += %w(users.css)
assets.precompile += %w(tests.css companies.css)
assets.precompile += %w(help.css)
assets.precompile += %w(competencies.js benchmarks.js sign_up.js)
assets.precompile += %w(candidates_bulk_upload.csv)
assets.precompile += %w(shared/reports/training_requirements/h_graph.css)
assets.precompile += %w(shared/reports/training_requirements/factor_scores.css)
assets.precompile += %w(training_requirements_report.css)
assets.precompile += %w(shared/reports/benchmarks/factor_benchmark.css)
assets.precompile += %w(walk_ins.css walk_ins.js training_requirements.css feedback.css)
