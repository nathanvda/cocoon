module Cocoon
  module CellsHelpers
    include ViewHelpers

    # :nodoc:
    def render_partial(partial, partial_options)
      render(view: partial, locals: partial_options)
    end

  end
end
