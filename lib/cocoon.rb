require 'cocoon/view_helpers'

module Cocoon
  class Engine < ::Rails::Engine

    config.before_initialize do
      if config.action_view.javascript_expansions
        config.action_view.javascript_expansions[:cocoon] = %w(cocoon)
      end
    end

    # configure our plugin on boot
    initializer "cocoon.initialize" do |app|
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, Cocoon::ViewHelpers
      end
    end

  end
end
