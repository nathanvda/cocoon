require 'cocoon/view_helpers'

module Cocoon
  class Engine < ::Rails::Engine

    config.before_initialize do
      config.action_view.javascript_expansions[:cocoon] = %w(cocoon)
    end

    # configure our plugin on boot
    initializer "cocoon.initialize" do |app|
      ActionView::Base.send :include, Cocoon::ViewHelpers

      if Object.const_defined?("Formtastic") and Formtastic.const_defined?("Inputs")
        require 'cocoon/formtastic/cocoon_input'
      end
    end

  end
end
