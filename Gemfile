source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
# Use pg as the database for Active Record
gem 'pg'
# required gem to deploy to Heroku
gem 'rails_12factor'
# Using oj for faster JSON parsing
gem 'oj'
gem 'oj_mimic_json'
# kaminari pagination
gem 'kaminari'
# Using impressionists for tracking
gem 'impressionist'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Using d3js for graphing
gem 'd3js-rails'
# Using slectize for cuter select
gem 'selectize-rails'
# Use Materialize
# gem 'materialize-sass'
# Using less because twitter bootstrap
# gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
# Using twitter bootstrap for styling
# gem "twitter-bootstrap-rails"

source 'http://rails-assets.org' do
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-bootstrap-material-design'
  gem 'rails-assets-bootstrap-select'
end

#Using breadcrumbs_on_rails for breadcrumbs
gem 'breadcrumbs_on_rails'
# Using Material icons
gem 'material_icons'
# Active link to will add active class for link of same controller
gem 'active_link_to'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Using device for user management
gem 'devise'
# Using omniauth for user
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'certified'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# jQuery Turbolinks
gem 'jquery-turbolinks'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Display progress bar
gem 'nprogress-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '3.1.11', :require => 'bcrypt'
# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
