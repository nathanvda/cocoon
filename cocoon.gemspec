# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "cocoon"
  spec.version       = "1.2.5"
  spec.authors       = ["Nathan Van der Auwera"]
  spec.email         = ["nathan@dixis.com"]
  spec.description   = %q{Unobtrusive nested forms handling, using jQuery. Use this and discover cocoon-heaven.}
  spec.summary       = %q{gem that enables easier nested forms with standard forms, formtastic and simple-form}
  spec.homepage      = "http://github.com/nathanvda/cocoon"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rails", "~> 4.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "json_pure"
  spec.add_development_dependency "rspec-rails", "~> 2.8"
  spec.add_development_dependency "rspec", "~> 2.8"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "generator_spec"
  spec.add_development_dependency "psych"
  spec.add_development_dependency "racc"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
