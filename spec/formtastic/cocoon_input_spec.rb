require 'spec_helper'
require 'cocoon/formtastic/cocoon_input'

describe CocoonInput do
  let(:input) { CocoonInput.new(builder, template, object, object_name, method, options) }
  let(:builder) { stub(:auto_index => false, :options => {}, :custom_namespace => nil, :all_fields_required_by_default => false) }
  let(:template) { stub }
  let(:object) { stub }
  let(:object_name) { :object }
  let(:method) { :nested }
  let(:options) { {} }

  describe '#wrapper_html_options' do
    subject { input.wrapper_html_options }

    context 'not ordered' do
      it 'should not be ordered' do
        subject.should_not have_key('data-ordered_by')
      end
    end

    context 'ordered' do
      let(:field) { :field }
      let(:options) { { :ordered_by => field } }

      it 'should be ordered' do
        subject['data-ordered_by'].should == field
      end
    end
  end

  describe '#links' do
    subject { input.links }

    before do
      template.stub(:content_tag).and_yield
      template.stub(:link_to_add_association)
      template.stub(:t)
    end

    it 'should generate the links holder' do
      subject
    end
  end

  describe '#semantic_fields_for' do
    subject { input.semantic_fields_for }

    before do
      builder.stub(:semantic_fields_for)
      template.stub(:render)
    end

    it 'should pass through to semantic_fields_for on the builder' do
      subject
    end
  end

  describe '#to_html' do
    subject { input.to_html }

    before do
      input.stub(:label_html).and_return('label')
      input.stub(:wrapped_semantic_fields).and_return('fields')
      input.stub(:links).and_return('links')
      template.stub(:content_tag)
    end

    it 'should concatenate the outputs and pass through to content_tag' do
      subject
    end
  end
end
