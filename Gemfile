source "https://rubygems.org"

# Required dependencies are specified in maruku.gemspec

gemspec

# Optional dependencies that we want to test with
gem 'syntax', '~> 1.1.0'
gem 'nokogiri', '~> 1.5'

if RUBY_PLATFORM != 'java'
   # itextomml won't build for jRuby, but we should test with it otherwise
  gem "itextomml", '~> 1.5.0'
end

# Rubinius is gemifying the standard library
platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'racc'
  gem 'json'
  gem 'rubinius-coverage'
end

# Development tools
gem 'rake', '~> 10.1.0'
gem 'rspec', '~> 2.14.1'
gem 'yard', '~> 0.8.7'
gem 'nokogiri-diff', '~> 0.2.0'
gem 'simplecov', '~> 0.7.1'
gem 'coveralls', :require => false
