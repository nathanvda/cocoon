require 'formtastic'

class CocoonInput
  include ::Formtastic::Inputs::Base

  def to_html
    output = label_html << semantic_fields_for << links

    template.content_tag(:li, output.html_safe, wrapper_html_options)
  end

  def wrapper_html_options
    data = super.merge(:class => 'input cocoon')
    if options[:ordered_by]
      data['data-ordered_by'] = options[:ordered_by]
    end

    data
  end

  def semantic_fields_for
    builder.semantic_fields_for(method) do |fields|
      if fields.object
        template.render :partial => "#{method.to_s.singularize}_fields", :locals => { :f => fields }
      end
    end
  end

  def links
    template.content_tag(:div, :class => 'links') do
      template.link_to_add_association template.t('.add'), builder, method, input_html_options
    end
  end
end

