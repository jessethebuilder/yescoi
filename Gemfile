source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use Puma as the app server
gem 'puma', '~> 3.0'

# gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
# gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "mongoid"#, git: 'git://github.com/mongoid/mongoid.git'

gem 'farm_ruby', :git => 'https://github.com/jessethebuilder/farm_ruby'
# gem 'farm_ruby', :path => 'C:\Users\Bucky\Desktop\jesseweb\farm_ruby'

gem 'farm_scrape', :git => 'https://github.com/jessethebuilder/farm_scrape'
# gem 'farm_scrape', :path => 'C:\Users\Bucky\Desktop\jesseweb\farm_scrape'

gem 'rest-client'

group :production do
  gem 'rails_12factor'
  # gem 'phantomjs', :require => 'phantomjs/poltergeist'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
