module Cocoon
  module ViewHelpers


    # this will show a link to remove the current association. This should be placed inside the partial.
    #
    # - *name* : the text of the link
    # - *f* : the form this link should be placed in
    def link_to_remove_association(name, f)
      is_dynamic = f.object.new_record?
      f.hidden_field(:_destroy) + link_to(name, '#', :class => "remove_fields #{is_dynamic ? 'dynamic' : 'existing'}")
    end

    # :nodoc:
    def render_association(association, f, new_object)
      f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render(association.to_s.singularize + "_fields", :f => builder, :dynamic => true)
      end
    end

    # shows a link that will allow to dynamically add a new associated object.
    #
    # - *name* :         the text to show in the link
    # - *f* :            the form this should come in (the formtastic form)
    # - *association* :  the associated objects, e.g. :tasks, this should be the name of the <tt>has_many</tt> relation.
    #
    def link_to_add_association(name, f, association)
      new_object = f.object.class.reflect_on_association(association).klass.new
      model_name = new_object.class.name.underscore
      hidden_div = content_tag('div', :id => "#{model_name}_fields_template", :style => "display:none;") do
        render_association(association, f, new_object)
      end
      hidden_div.html_safe + link_to(name, '#', :class => 'add_fields', :'data-association' => association.to_s.singularize)
    end

  end
end
