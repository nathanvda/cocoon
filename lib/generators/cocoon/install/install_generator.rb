module Cocoon
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc "This generator installs the javascript needed for cocoon"
      def copy_the_javascript
        if ::Rails.version[0..2].to_f >= 3.1
          puts "Installing is no longer required since Rails 3.1"
        else
          copy_file "../../../../../app/assets/javascripts/cocoon.js", "public/javascripts/cocoon.js"
        end
      end

    end
  end
end