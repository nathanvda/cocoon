module Cocoon
  module CellsHelpers
    include ViewHelpers

    # :nodoc:
    def render_partial(partial, partial_options)
      render(view: partial, locals: partial_options)
    end

    # :nodoc:
    def insertion_template(association, f, new_object, form_parameter_name, render_options, override_partial)
      CGI.unescapeHTML(render_association(association, f, new_object, form_parameter_name, render_options, override_partial).to_str).html_safe
    end

  end
end
