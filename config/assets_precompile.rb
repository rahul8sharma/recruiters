# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
assets = Rails.application.config.assets
assets.paths << "#{Rails.root}/app/assets/files"
assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
assets.precompile += %w(toolkit/main-layout.css)
assets.precompile += %w(admin.css)
assets.precompile += %w(application.js jquery.js jquery_ujs.js admin.js reports.js norms.js styles.js)
assets.precompile += %w(shared.css reports.css)
assets.precompile += %w(users.css)
assets.precompile += %w(tests.css companies.css)
assets.precompile += %w(help.css)
assets.precompile += %w(competencies.js)
assets.precompile += %w(candidates_bulk_upload.csv)
