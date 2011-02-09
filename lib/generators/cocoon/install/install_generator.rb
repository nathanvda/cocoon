module Cocoon
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "This generator installs the javascript needed for cocoon"

      def copy_the_javascript
        copy_file "cocoon.js", "public/javascripts/cocoon.js"
      end

    end
  end
end