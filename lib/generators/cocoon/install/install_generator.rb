module Cocoon
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      if ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1
        # for Rails 3.1 no installing is needed anymore, because of the asset pipeline
        desc "Installing is only needed for rails 3.0.x"
        def do_nothing
          puts "Installing is no longer required since Rails 3.1"
        end
      else
        desc "This generator installs the javascript needed for cocoon"
        def copy_the_javascript
          copy_file "../../../app/assets/javascripts/cocoon.js", "public/javascripts/cocoon.js"
        end
      end

    end
  end
end