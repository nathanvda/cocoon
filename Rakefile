# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rdoc/task'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'erb'
require 'JSON'


RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cocoon'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cocoon"
    gem.summary = %Q{gem that enables easier nested forms with standard forms, formtastic and simple-form}
    gem.description = %Q{Unobtrusive nested forms handling, using jQuery. Use this and discover cocoon-heaven.}
    gem.email = "nathan@dixis.com"
    gem.homepage = "http://github.com/nathanvda/cocoon"
    gem.authors = ["Nathan Van der Auwera"]
    gem.licenses = ["MIT"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


require 'bundler/gem_tasks'

spec = Bundler.load_gemspec('./cocoon.gemspec')


npm_src_dir = './npm'
npm_dest_dir = './dist'
CLOBBER.include 'dist'

assets_dir = './app/assets/'

npm_files = {
    File.join(npm_dest_dir, 'cocoon.js') => File.join(assets_dir, 'javascripts', 'cocoon.js'),
    File.join(npm_dest_dir, 'README.md') => File.join(npm_src_dir, 'README.md'),
    File.join(npm_dest_dir, 'LICENSE') => './LICENSE'
}

namespace :npm do
  npm_files.each do |dest, src|
    file dest => src do
      cp src, dest
    end
  end

  task :'package-json' do
    template = ERB.new(File.read(File.join(npm_src_dir, 'package.json.erb')))
    content = template.result_with_hash(spec: spec)
    File.write(File.join(npm_dest_dir, 'package.json'),
               JSON.pretty_generate(JSON.parse(content)))
  end

  desc "Build nathanvda-cocoon-#{spec.version}.tgz into the pkg directory"
  task build: (%i[package-json] + npm_files.keys) do
    system("cd #{npm_dest_dir} && npm pack && mv ./nathanvda-cocoon-#{spec.version}.tgz ../pkg/")
  end

  desc "Build and push nathanvda-cocoon-#{spec.version}.tgz to https://npmjs.org"
  task release: %i[build] do
    system("npm publish ./pkg/nathanvda-cocoon-#{spec.version}.tgz --access public")
  end
end

