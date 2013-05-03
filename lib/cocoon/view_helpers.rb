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
      sub_to_remove_association(:link_to, *args, &block)
    end
    
    def sub_to_remove_association(function_name, *args, &block)
      if block_given?
        f            = args.first
        html_options = args.second || {}
        name         = capture(&block)
        sub_to_remove_association(function_name, name, f, html_options)
      else
        name         = args[0]
        f            = args[1]
        html_options = args[2] || {}

        is_dynamic = f.object.new_record?
        html_options[:class] = [html_options[:class], "remove_fields #{is_dynamic ? 'dynamic' : 'existing'}"].compact.join(' ')
        hidden_field_tag("#{f.object_name}[_destroy]") + self.send(function_name, name, '#', html_options )
      end
    end
    
    # this will show a button to remove the current association. This should be placed inside the partial.
    # either you give
    # - *name* : the text of the button
    # - *f* : the form this link should be placed in
    # - *html_options*:  html options to be passed to link_to (see <tt>link_to</tt>)
    #
    # or you use the form without *name* with a *&block*
    # - *f* : the form this button should be placed in
    # - *html_options*:  html options to be passed to button_to_function (see <tt>button_to_function</tt>)
    # - *&block*:        the output of the block will be show in the link, see <tt>button_to_function</tt>
    
    def button_to_remove_association(*args, &block)
      sub_to_remove_association(:button_to_function, *args, &block)
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
    #          - *:wrap_object     : !!! document more here !!!
    #          - *!!!add some option to build in collection or not!!!*
    # - *&block*:        see <tt>link_to</tt>

    def link_to_add_association(*args, &block)
      sub_add_association(:link_to, *args, &block)
    end
    
    def sub_add_association(function_name, *args, &block)
      if block_given?
        f            = args[0]
        association  = args[1]
        html_options = args[2] || {}
        sub_add_association(function_name, capture(&block), f, association, html_options)
      else
        name         = args[0]
        f            = args[1]
        association  = args[2]
        html_options = args[3] || {}

        render_options   = html_options.delete(:render_options)
        render_options ||= {}
        override_partial = html_options.delete(:partial)
        wrap_object = html_options.delete(:wrap_object)
        force_non_association_create = html_options.delete(:force_non_association_create) || false

        html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
        html_options[:'data-association'] = association.to_s.singularize
        html_options[:'data-associations'] = association.to_s.pluralize

        new_object = create_object(f, association, force_non_association_create)
        new_object = wrap_object.call(new_object) if wrap_object.respond_to?(:call)

        html_options[:'data-association-insertion-template'] = CGI.escapeHTML(render_association(association, f, new_object, render_options, override_partial)).html_safe

        self.send(function_name, name, '#', html_options )
      end
    end

    # shows a button that will allow to dynamically add a new associated object.
    #
    # - *name* :         the text to show in the button
    # - *f* :            the form this should come in (the formtastic form)
    # - *association* :  the associated objects, e.g. :tasks, this should be the name of the <tt>has_many</tt> relation.
    # - *html_options*:  html options to be passed to <tt>button_to_function</tt> (see <tt>button_to_function</tt>)
    #          - *:render_options* : options passed to `simple_fields_for, semantic_fields_for or fields_for`
    #              - *:locals*     : the locals hash in the :render_options is handed to the partial
    #          - *:partial*        : explicitly override the default partial name
    #          - *:wrap_object     : !!! document more here !!!
    #          - *!!!add some option to build in collection or not!!!*
    # - *&block*:        see <tt>button_to_function</tt>

    def button_to_add_association(*args, &block)
      sub_add_association(:button_to_function, *args, &block)
    end

    # creates new association object with its conditions, like
    # `` has_many :admin_comments, class_name: "Comment", conditions: { author: "Admin" }
    # will create new Comment with author "Admin"

    def create_object(f, association, force_non_association_create=false)
      assoc = f.object.class.reflect_on_association(association)

      assoc ? create_object_on_association(f, association, assoc, force_non_association_create) : create_object_on_non_association(f, association)
    end

    def get_partial_path(partial, association)
      partial ? partial : association.to_s.singularize + "_fields"
    end

    private

    def create_object_on_non_association(f, association)
      builder_method = %W{build_#{association} build_#{association.to_s.singularize}}.select { |m| f.object.respond_to?(m) }.first
      return f.object.send(builder_method) if builder_method
      raise "Association #{association} doesn't exist on #{f.object.class}"
    end

    def create_object_on_association(f, association, instance, force_non_association_create)
      if instance.class.name == "Mongoid::Relations::Metadata" || force_non_association_create
        create_object_with_conditions(instance)
      else
        # assume ActiveRecord or compatible
        if instance.collection?
          f.object.send(association).build
        else
          f.object.send("build_#{association}")
        end
      end
    end

    def create_object_with_conditions(instance)
      conditions = instance.respond_to?(:conditions) ? instance.conditions.flatten : []
      instance.klass.new(*conditions)
    end

  end
end
