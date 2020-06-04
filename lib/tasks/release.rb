namespace :release do
  root    = File.expand_path("../..", __dir__)
  version = File.read("VERSION").strip

  # "5.0.1"     --> "5.0.1"
  # "5.0.1.1"   --> "5.0.1-1" *
  # "5.0.0.rc1" --> "5.0.0-rc1"
  #
  # * This makes it a prerelease. That's bad, but we haven't come up with
  # a better solution at the moment.
  npm_version = version.gsub(/\./).with_index { |s, i| i >= 2 ? "-" : s }

  task :update_npm_version do
    system "npm version #{npm_version} --no-git-tag-version"
  end
end
