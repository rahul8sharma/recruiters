source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.6'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyrhino', '2.0.4'
# Use jquery as the JavaScript library
gem 'jquery-rails', '4.3.1'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'sprockets', '3.4'
gem 'sprockets-rails', '2.3.3'

group :assets do
  gem 'sass', '3.5.6'
  gem 'bootstrap-sass', '3.3.7'
end

gem 'oauth2', '1.4.0'

gem 'haml-rails', '1.0.0'

gem 'rails-backbone', '1.2.0'

gem 'kaminari', :github => "amatsuda/kaminari", :branch => "master", :ref => "c7c88c576786"

gem 'wicked_pdf'

gem 'faraday', :github => "prcongithub/faraday", :branch => "handle-unprocessable-entity", :ref => "dca594d4664e42476826d098053135b304242614"

gem 'her', '0.6.8'
gem 'spreadsheet', '1.1.1'

gem 'vger', :git => "git@github.com:yournextleap/vger.git", :branch => "develop"

gem 'faraday_middleware', '0.12.2'
gem 'awesome_print', '1.8.0'
gem 'request_store', '1.4.1'
#gem 'roo'
gem "exception_notification", '4.2.2'

gem 'aws-sdk', '3.0.1'

gem 'slim', '3.0.9'
gem 'sinatra', '2.0.1'
gem 'sidekiq', '5.1.1'

gem 'jombay-notify',  :git => "git@bitbucket.org:jombay/jombay-notify.git", :branch => "rails-5"
# TODO remove attr_accessible in JombayNotify::Notification

gem 'celluloid-redis', '0.0.2'
gem 'listen', '3.1.5'

platform :ruby do
  group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
  end
end

group :development do
  gem 'pry' 	
  gem "letter_opener"
  gem 'meta_request'
end

gem "redis-namespace", "~> 1.6"
