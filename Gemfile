source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
ruby '~> 2.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

gem 'rails', '~> 5.1.5'
# Use sqlite3 as the database for Active Record

# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'omniauth-google-oauth2'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'devise'
gem 'omniauth-facebook'
gem 'carrierwave'

# Automate using jQuery with Rails https://github.com/rails/jquery-rails
gem 'jquery-rails'

# Use bootstrap with rails https://rubygems.org/gems/bootstrap
gem 'bootstrap'

# Use font awesome with rails https://rubygems.org/gems/font-awesome-rails/versions/4.7.0.2
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'

#Use bootstrap-select-rails https://github.com/silviomoreto/bootstrap-select
gem 'bootstrap-select-rails'

gem 'cloudinary'

gem 'csv'

# Use carrierwave
gem 'carrierwave'

# Use kaminari https://github.com/kaminari/kaminari 
gem 'kaminari', '~>1.1.1'

# User slick for carousel animation https://github.com/bodrovis/jquery-slick-rails
gem "jquery-slick-rails"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'capistrano-rails'
  gem 'capistrano-passenger'

  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'sqlite3'
  # for web scraping
  gem 'watir'       # https://github.com/watir/watir
  gem 'mechanize'   # https://github.com/sparklemotion/mechanize
end

group :production do
  #gem 'pg', '~> 0.18'
  gem "mysql2"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  #Help to find N+1 query https://github.com/flyerhzm/bullet
  gem 'bullet'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
