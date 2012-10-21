require 'formtastic'

class CocoonInput
  include ::Formtastic::Inputs::Base

  def to_html
    output = []

    output << label_html

    output << builder.semantic_fields_for(method) do |fields|
      if fields.object
        template.render :partial => "#{method.to_s.singularize}_fields", :locals => { :f => fields }
      end
    end

    output << template.content_tag(:div, :class => 'links') do
      template.link_to_add_association template.t('.add'), builder, method, input_html_options
    end

    template.content_tag(:li, output.join('').html_safe, wrapper_html_options)
  end
end

