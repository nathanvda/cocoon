require 'cocoon/view_helpers'

module Cocoon
  class Railtie < ::Rails::Railtie

    config.before_initialize do
      config.action_view.javascript_expansions[:cocoon] = %w(cocoon)
    end

    # configure our plugin on boot
    initializer "cocoon.initialize" do |app|
      ActionView::Base.send :include, Cocoon::ViewHelpers
    end

  end
end