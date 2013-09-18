# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
assets = Rails.application.config.assets
assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
assets.precompile += %w(toolkit/main-layout.css)
assets.precompile += %w(admin.css)
assets.precompile += %w(application.js jquery.js jquery_ujs.js admin.js reports.js)
assets.precompile += %w(shared.css reports.css)
assets.precompile += %w(users.css)
assets.precompile += %w(tests.css companies.css)
