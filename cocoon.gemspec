Gem::Specification.new do |s|
  s.name = "cocoon"
  s.version = "1.2.8"

  s.authors = ["Nathan Van der Auwera"]
  s.email = "nathan@dixis.com"

  s.description = "Unobtrusive nested forms handling, using jQuery. Use this and discover cocoon-heaven."
  s.summary = "gem that enables easier nested forms with standard forms, formtastic and simple-form"
  s.homepage = "http://github.com/nathanvda/cocoon"
  s.licenses = ["MIT"]

  s.extra_rdoc_files = ["README.markdown"]
  s.files = `git ls-files`.split("\n").sort
  s.require_paths = ["lib"]
end
