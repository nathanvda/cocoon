module Cocoon
  module ViewHelpers


    # this will show a link to remove the current association. This should be placed inside the partial.
    # either you give
    # - *name* : the text of the link
    # - *f* : the form this link should be placed in
    # - *html_options*:  html options to be passed to link_to (see <tt>link_to</tt>)
    #
    # or you use the form without *name* with a *&block*
    # - *f* : the form this link should be placed in
    # - *html_options*:  html options to be passed to link_to (see <tt>link_to</tt>)
    # - *&block*:        the output of the block will be show in the link, see <tt>link_to</tt>
    
    def link_to_remove_association(*args, &block)
      if block_given?
        f            = args.first
        html_options = args.second || {}
        name         = capture(&block)
        link_to_remove_association(name, f, html_options)
      else
        name         = args[0]
        f            = args[1]
        html_options = args[2] || {}

        is_dynamic = f.object.new_record?
        html_options[:class] = [html_options[:class], "remove_fields #{is_dynamic ? 'dynamic' : 'existing'}"].compact.join(' ')
        hidden_field_tag("#{f.object_name}[_destroy]") + link_to(name, '#', html_options)
      end
    end

    # :nodoc:
    def render_association(association, f, new_object, render_options={}, custom_partial=nil)
      partial = get_partial_path(custom_partial, association)
      locals =  render_options.delete(:locals) || {}
      method_name = f.respond_to?(:semantic_fields_for) ? :semantic_fields_for : (f.respond_to?(:simple_fields_for) ? :simple_fields_for : :fields_for)
      f.send(method_name, association, new_object, {:child_index => "new_#{association}"}.merge(render_options)) do |builder|
        partial_options = {:f => builder, :dynamic => true}.merge(locals)
        render(partial, partial_options)
      end
    end

    # shows a link that will allow to dynamically add a new associated object.
    #
    # - *name* :         the text to show in the link
    # - *f* :            the form this should come in (the formtastic form)
    # - *association* :  the associated objects, e.g. :tasks, this should be the name of the <tt>has_many</tt> relation.
    # - *html_options*:  html options to be passed to <tt>link_to</tt> (see <tt>link_to</tt>)
    #          - *:render_options* : options passed to `simple_fields_for, semantic_fields_for or fields_for`
    #              - *:locals*     : the locals hash in the :render_options is handed to the partial
    #          - *:partial*        : explicitly override the default partial name
    # - *&block*:        see <tt>link_to</tt>

    def link_to_add_association(*args, &block)
      if block_given?
        f            = args[0]
        association  = args[1]
        html_options = args[2] || {}
        link_to_add_association(capture(&block), f, association, html_options)
      else
        name         = args[0]
        f            = args[1]
        association  = args[2]
        html_options = args[3] || {}

        render_options   = html_options.delete(:render_options)
        render_options ||= {}
        override_partial = html_options.delete(:partial)

        html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
        html_options[:'data-association'] = association.to_s.singularize
        html_options[:'data-associations'] = association.to_s.pluralize

        new_object = create_object(f, association)
        html_options[:'data-template'] = CGI.escapeHTML(render_association(association, f, new_object, render_options, override_partial)).html_safe

        link_to(name, '#', html_options )
      end
    end

    # creates new association object with its conditions, like
    # `` has_many :admin_comments, class_name: "Comment", conditions: { author: "Admin" }
    # will create new Comment with author "Admin"

    def create_object(f, association)
      assoc = f.object.class.reflect_on_association(association)

      if assoc.collection?
        f.object.send(association).build
      else
        f.object.send("build_#{association}")
      end
    end

    def get_partial_path(partial, association)
      partial ? partial : association.to_s.singularize + "_fields"
    end

  end
end
