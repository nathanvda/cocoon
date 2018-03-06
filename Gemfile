source "http://rubygems.org"


group :development, :test do
  gem "rails", "~> 4.2"
  gem "sqlite3", '1.3.13'
  gem "json_pure"
  # Requires ruby version >= 2.2.2.
  # https://github.com/technicalpickles/jeweler/commit/6e1fc653b79a85a87b20274fa3e5d28dca8c9e15#diff-085ee3a98b1501b5e8fe6c41b7f4a348R193
  gem "jeweler", "< 2.3"
  # Requires ruby version >= 2.2.2.
  # https://github.com/ruby/rdoc/commit/51b03c357457183e94a6b26d71630f183afbc6b0#diff-a3e11f586091452d2935675e4439ad53R49
  gem "rdoc", "< 6"
  gem "rspec-rails", "~> 3.0.0"
  gem "rspec",       "~> 3.0.0"
  gem "actionpack",  ">=4.0.0"
  gem "simplecov", :require => false
  gem "rake", "~> 10.1"

  gem 'nokogiri'

  gem "generator_spec"

  platforms :rbx do
    gem 'rubysl'
    gem 'rubysl-test-unit'
    gem 'psych', '~> 2.2'
    gem 'racc'
    gem 'rubinius-developer_tools'
  end

end


# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'
