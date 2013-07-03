# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
assets = Rails.application.config.assets
assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
assets.precompile += %w(shared.css)
