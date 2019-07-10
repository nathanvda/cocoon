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
        link_to_remove_association(capture(&block), *args)
      elsif args.first.respond_to?(:object)
        form = args.first
        association = form.object.class.to_s.tableize
        name = I18n.translate("cocoon.#{association}.remove", default: I18n.translate('cocoon.defaults.remove'))

        link_to_remove_association(name, *args)
      else
        name, f, html_options = *args
        html_options ||= {}

        is_dynamic = f.object.new_record?

        classes = []
        classes << "remove_fields"
        classes << (is_dynamic ? 'dynamic' : 'existing')
        classes << 'destroyed' if f.object.marked_for_destruction?
        html_options[:class] = [html_options[:class], classes.join(' ')].compact.join(' ')

        wrapper_class = html_options.delete(:wrapper_class)
        html_options[:'data-wrapper-class'] = wrapper_class if wrapper_class.present?

        f.hidden_field(:_destroy, value: f.object._destroy) + link_to(name, '#', html_options)
      end
    end

    # :nodoc:
    def render_association(association, f, new_object, form_name, received_render_options={}, custom_partial=nil)
      partial = get_partial_path(custom_partial, association)
      render_options = received_render_options.dup
      locals =  render_options.delete(:locals) || {}
      ancestors = f.class.ancestors.map{|c| c.to_s}
      method_name = ancestors.include?('SimpleForm::FormBuilder') ? :simple_fields_for : (ancestors.include?('Formtastic::FormBuilder') ? :semantic_fields_for : :fields_for)
      f.send(method_name, association, new_object, {:child_index => "new_#{association}"}.merge(render_options)) do |builder|
        partial_options = {form_name.to_sym => builder, :dynamic => true}.merge(locals)
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
    #          - *:wrap_object*    : a proc that will allow to wrap your object, especially suited when using
    #                                decorators, or if you want special initialisation
    #          - *:form_name*      : the parameter for the form in the nested form partial. Default `f`.
    #          - *:count*          : Count of how many objects will be added on a single click. Default `1`.
    # - *&block*:        see <tt>link_to</tt>

    def link_to_add_association(*args, &block)
      if block_given?
        link_to_add_association(capture(&block), *args)
      elsif args.first.respond_to?(:object)
        association = args.second
        name = I18n.translate("cocoon.#{association}.add", default: I18n.translate('cocoon.defaults.add'))

        link_to_add_association(name, *args)
      else
        name, f, association, html_options = *args
        html_options ||= {}

        render_options   = html_options.delete(:render_options)
        render_options ||= {}
        override_partial = html_options.delete(:partial)
        wrap_object = html_options.delete(:wrap_object)
        force_non_association_create = html_options.delete(:force_non_association_create) || false
        form_parameter_name = html_options.delete(:form_name) || 'f'
        count = html_options.delete(:count).to_i

        html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
        html_options[:'data-association'] = association.to_s.singularize
        html_options[:'data-associations'] = association.to_s.pluralize

        new_object = create_object(f, association, force_non_association_create)
        new_object = wrap_object.call(new_object) if wrap_object.respond_to?(:call)

        html_options[:'data-association-insertion-template'] = CGI.escapeHTML(render_association(association, f, new_object, form_parameter_name, render_options, override_partial).to_str).html_safe

        html_options[:'data-count'] = count if count > 0

        link_to(name, '#', html_options)
      end
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
      if instance.class.name.starts_with?('Mongoid::') || force_non_association_create
        create_object_with_conditions(instance)
      else
        assoc_obj = nil

        # assume ActiveRecord or compatible
        if instance.collection?
          assoc_obj = f.object.send(association).build
          f.object.send(association).delete(assoc_obj)
        else
          assoc_obj = f.object.send("build_#{association}")
          f.object.send(association).delete
        end

        assoc_obj = assoc_obj.dup if assoc_obj.frozen?

        assoc_obj
      end
    end

    def create_object_with_conditions(instance)
      # in rails 4, an association is defined with a proc
      # and I did not find how to extract the conditions from a scope
      # except building from the scope, but then why not just build from the
      # association???
      conditions = instance.respond_to?(:conditions) ? instance.conditions.flatten : []
      instance.klass.new(*conditions)
    end

  end
end
