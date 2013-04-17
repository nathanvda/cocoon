require 'cocoon/view_helpers'

module Cocoon
  class Engine < ::Rails::Engine

    # configure our plugin on boot
    initializer "cocoon.initialize" do |app|
      ActionView::Base.send :include, Cocoon::ViewHelpers
    end

  end
end