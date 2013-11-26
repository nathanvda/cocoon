require 'spec_helper'
require 'nokogiri'

describe Cocoon do
  class TestClass < ActionView::Base

  end

  subject {TestClass.new}

  it { should respond_to(:link_to_add_association) }
  it { should respond_to(:link_to_remove_association) }

  before(:each) do
    @tester = TestClass.new
    @post = Post.new
    @form_obj = double(:object => @post, :object_name => @post.class.name)
  end


  context "link_to_add_association" do
    before(:each) do
      @tester.stub(:render_association).and_return('form<tag>')
    end

    context "without a block" do

      context "and given a name" do
        before do
          @html = @tester.link_to_add_association('add something', @form_obj, :comments)
        end

        it_behaves_like "a correctly rendered add link", {}
      end

      context "and given html options to pass them to link_to" do
        before do
          @html = @tester.link_to_add_association('add something', @form_obj, :comments, {:class => 'something silly'})
        end

        it_behaves_like "a correctly rendered add link", {class: 'something silly add_fields' }
      end

      context "and explicitly specifying the wanted partial" do
        before do
          @tester.unstub(:render_association)
          @tester.should_receive(:render_association).with(anything(), anything(), anything(), "f", anything(), "shared/partial").and_return('partiallll')
          @html = @tester.link_to_add_association('add something', @form_obj, :comments, :partial => "shared/partial")
        end

        it_behaves_like "a correctly rendered add link", {template: "partiallll"}
      end

      it "gives an opportunity to wrap/decorate created objects" do
        @tester.unstub(:render_association)
        @tester.should_receive(:render_association).with(anything(), anything(), kind_of(CommentDecorator), "f", anything(), anything()).and_return('partiallll')
        @tester.link_to_add_association('add something', @form_obj, :comments, :wrap_object => Proc.new {|comment| CommentDecorator.new(comment) })
      end

      context "force non association create" do
        context "default case: create object on association" do
          before do
            @tester.should_receive(:create_object).with(anything, :comments , false)
            @html = @tester.link_to_add_association('add something', @form_obj, :comments)
          end

          it_behaves_like "a correctly rendered add link", {}
        end

        context "and explicitly specifying false is the same as default" do
          before do
            @tester.should_receive(:create_object).with(anything, :comments , false)
            @html = @tester.link_to_add_association('add something', @form_obj, :comments, :force_non_association_create => false)
          end
          it_behaves_like "a correctly rendered add link", {}
        end

        context "specifying true will not create objects on association but using the conditions" do
          before do
            @tester.should_receive(:create_object).with(anything, :comments , true)
            @html = @tester.link_to_add_association('add something', @form_obj, :comments, :force_non_association_create => true)
          end
          it_behaves_like "a correctly rendered add link", {}
        end
      end
    end

    context "with a block" do
      context "and the block specifies the link text" do
        before do
          @html = @tester.link_to_add_association(@form_obj, :comments) do
            "some long name"
          end
        end
        it_behaves_like "a correctly rendered add link", {text: 'some long name'}
      end

      context "accepts html options and pass them to link_to" do
        before do
          @html = @tester.link_to_add_association(@form_obj, :comments, {:class => 'floppy disk'}) do
            "some long name"
          end
        end
        it_behaves_like "a correctly rendered add link", {class: 'floppy disk add_fields', text: 'some long name'}
      end

      context "accepts extra attributes and pass them to link_to" do
        context 'when using the old notation' do
          before do
            @html = @tester.link_to_add_association(@form_obj, :comments, {:class => 'floppy disk', 'data-something' => 'bla'}) do
              "some long name"
            end
          end
          it_behaves_like "a correctly rendered add link", {class: 'floppy disk add_fields', text: 'some long name', :extra_attributes => {'data-something' => 'bla'}}
        end
        if Rails.rails4?
          context 'when using the new notation' do
            before do
              @html = @tester.link_to_add_association(@form_obj, :comments, {:class => 'floppy disk', :data => {:'association-something' => 'foobar'}}) do
                "some long name"
              end
            end
            it_behaves_like "a correctly rendered add link", {class: 'floppy disk add_fields', text: 'some long name', :extra_attributes => {'data-association-something' => 'foobar'}}
          end
        end
      end

      context "and explicitly specifying the wanted partial" do
        before do
          @tester.unstub(:render_association)
          @tester.should_receive(:render_association).with(anything(), anything(), anything(), "f", anything(), "shared/partial").and_return('partiallll')
          @html = @tester.link_to_add_association( @form_obj, :comments, :class => 'floppy disk', :partial => "shared/partial") do
            "some long name"
          end
        end

        it_behaves_like "a correctly rendered add link", {class: 'floppy disk add_fields', template: "partiallll", text: 'some long name'}
      end
    end

    context "with an irregular plural" do
      context "uses the correct plural" do
        before do
          @html = @tester.link_to_add_association('add something', @form_obj, :people)
        end
        it_behaves_like "a correctly rendered add link", {association: 'person', associations: 'people' }
      end
    end

    context "when using aliased association and class-name" do
      context "uses the correct name" do
        before do
          @html = @tester.link_to_add_association('add something', @form_obj, :admin_comments)
        end
        it_behaves_like "a correctly rendered add link", {association: 'admin_comment', associations: 'admin_comments'}
      end
    end

    it "tttt" do
      @post.class.reflect_on_association(:people).klass.new.should be_a(Person)
    end

    context "with extra render-options for rendering the child relation" do
      context "uses the correct plural" do
        before do
          @tester.should_receive(:render_association).with(:people, @form_obj, anything, "f", {:wrapper => 'inline'}, nil)
          @html = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline'})
        end
        it_behaves_like "a correctly rendered add link", {association: 'person', associations: 'people' }
      end
    end

    context "passing locals to the partial" do
      context "when given: passes the locals to the partials" do
        before do
          @tester.unstub(:render_association)
          @form_obj.should_receive(:fields_for) { | association, new_object, options_hash, &block| block.call }
          @tester.should_receive(:render).with("person_fields", {:f=>nil, :dynamic=>true, :alfred=>"Judoka"}).and_return ("partiallll")
          @html = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline', :locals => {:alfred => 'Judoka'}})
        end
        it_behaves_like "a correctly rendered add link", {template: 'partiallll', association: 'person', associations: 'people' }
      end
      context "if no locals are given it still works" do
        before do
          @tester.unstub(:render_association)
          @form_obj.should_receive(:fields_for) { | association, new_object, options_hash, &block| block.call }
          @tester.should_receive(:render).with("person_fields", {:f=>nil, :dynamic=>true}).and_return ("partiallll")
          @html = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline'})
        end
        it_behaves_like "a correctly rendered add link", {template: 'partiallll', association: 'person', associations: 'people' }

        #result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="partiallll" data-association="person" data-associations="people">add something</a>'
      end
    end

    context "overruling the form parameter name" do
      context "when given a form_name it passes it correctly to the partials" do
        before do
          @tester.unstub(:render_association)
          @form_obj.should_receive(:fields_for) { | association, new_object, options_hash, &block| block.call }
          @tester.should_receive(:render).with("person_fields", {:people_form => nil, :dynamic=>true}).and_return ("partiallll")
          @html = @tester.link_to_add_association('add something', @form_obj, :people, :form_name => 'people_form')
        end
        it_behaves_like "a correctly rendered add link", {template: 'partiallll', association: 'person', associations: 'people' }
      end
    end


    context "when using formtastic" do
      before(:each) do
        @tester.unstub(:render_association)
        @form_obj.stub(:semantic_fields_for).and_return('form<tagzzz>')
      end
      context "calls semantic_fields_for and not fields_for" do
        before do
          @form_obj.should_receive(:semantic_fields_for)
          @form_obj.should_receive(:fields_for).never
          @html = @tester.link_to_add_association('add something', @form_obj, :people)
        end
        it_behaves_like "a correctly rendered add link", {template: 'form<tagzzz>', association: 'person', associations: 'people' }
      end
    end
    context "when using simple_form" do
      before(:each) do
        @tester.unstub(:render_association)
        @form_obj.stub(:simple_fields_for).and_return('form<tagxxx>')
      end
      it "responds_to :simple_fields_for" do
        @form_obj.should respond_to(:simple_fields_for)
      end
      context "calls simple_fields_for and not fields_for" do
        before do
          @form_obj.should_receive(:simple_fields_for)
          @form_obj.should_receive(:fields_for).never
          @html = @tester.link_to_add_association('add something', @form_obj, :people)
        end
        it_behaves_like "a correctly rendered add link", {template: 'form<tagxxx>', association: 'person', associations: 'people' }
      end
    end

    context 'when adding a count' do
      before do
        @html = @tester.link_to_add_association('add something', @form_obj, :comments, { :count => 3 })
      end
      it_behaves_like "a correctly rendered add link", { :extra_attributes => { 'data-count' => '3' } }
    end

  end

  context "link_to_remove_association" do
    context "without a block" do
      context "accepts a name" do
        before do
          @html = @tester.link_to_remove_association('remove something', @form_obj)
        end

        it "is rendered inside a input element" do
          doc = Nokogiri::HTML(@html)
          removed = doc.at('input')
          removed.attribute('id').value.should == "Post__destroy"
          removed.attribute('name').value.should == "Post[_destroy]"
          removed.attribute('value').value.should == "false"
        end

        it_behaves_like "a correctly rendered remove link", {}
      end

      context "accepts html options and pass them to link_to" do
        before do
          @html = @tester.link_to_remove_association('remove something', @form_obj, {:class => 'add_some_class', :'data-something' => 'bla'})
        end
        it_behaves_like "a correctly rendered remove link", {class: 'add_some_class remove_fields dynamic', extra_attributes: {'data-something' => 'bla'}}
      end

    end

    # this is needed when due to some validation error, objects that
    # were already marked for destruction need to remain hidden
    context "for a object marked for destruction" do
      before do
        @post_marked_for_destruction = Post.new
        @post_marked_for_destruction.mark_for_destruction
        @form_obj_destroyed = double(:object => @post_marked_for_destruction, :object_name => @post_marked_for_destruction.class.name)
        @html = @tester.link_to_remove_association('remove something', @form_obj_destroyed)
      end

      it "is rendered inside a input element" do
        doc = Nokogiri::HTML(@html)
        removed = doc.at('input')
        removed.attribute('id').value.should == "Post__destroy"
        removed.attribute('name').value.should == "Post[_destroy]"
        removed.attribute('value').value.should == "true"
      end

      it_behaves_like "a correctly rendered remove link", {class: 'remove_fields dynamic destroyed'}
    end

    context "with a block" do
      context "the block gives the name" do
        before do
          @html = @tester.link_to_remove_association(@form_obj) do
            "remove some long name"
          end
        end
        it_behaves_like "a correctly rendered remove link", {text: 'remove some long name'}
      end

      context "accepts html options and pass them to link_to" do
        before do
          @html = @tester.link_to_remove_association(@form_obj, {:class => 'add_some_class', :'data-something' => 'bla'}) do
            "remove some long name"
          end
        end
        it_behaves_like "a correctly rendered remove link", {text: 'remove some long name', class: 'add_some_class remove_fields dynamic', extra_attributes: {'data-something' => 'bla'}}
      end
    end

    context 'when changing the wrapper class' do
      context 'should use the default nested-fields class' do
        before do
          @html = @tester.link_to_remove_association('remove something', @form_obj)
        end

        it_behaves_like "a correctly rendered remove link", { }
      end

      context 'should use the given wrapper class' do
        before do
          @html = @tester.link_to_remove_association('remove something', @form_obj, { wrapper_class: 'another-class' })
        end
  
        it_behaves_like "a correctly rendered remove link", { extra_attributes: { 'data-wrapper-class' => 'another-class' } }
      end
    end
  end

  context "create_object" do
    it "creates correct association with conditions" do
      @tester.should_not_receive(:create_object_with_conditions)
      # in rails4 we cannot create an associated object when the object has not been saved before
      # I submitted a bug for this: https://github.com/rails/rails/issues/11376
      if Rails.rails4?
        @post = Post.create(title: 'Testing')
        @form_obj = double(:object => @post, :object_name => @post.class.name)
      end
      result = @tester.create_object(@form_obj, :admin_comments)
      result.author.should == "Admin"
      @form_obj.object.admin_comments.should be_empty
    end

    it "creates correct association for belongs_to associations" do
      comment  = Comment.new
      form_obj = double(:object => Comment.new)
      result   = @tester.create_object(form_obj, :post)
      result.should be_a Post
      comment.post.should be_nil
    end

    it "raises an error if cannot reflect on association" do
      expect { @tester.create_object(double(:object => Comment.new), :not_existing) }.to raise_error /association/i
    end

    it "creates an association if object responds to 'build_association' as singular" do
      object = Comment.new
      object.should_receive(:build_custom_item).and_return 'custom'
      @tester.create_object(double(:object => object), :custom_item).should == 'custom'
    end

    it "creates an association if object responds to 'build_association' as plural" do
      object = Comment.new
      object.should_receive(:build_custom_item).and_return 'custom'
      @tester.create_object(double(:object => object), :custom_items).should == 'custom'
    end

    it "can create using only conditions not the association" do
      @tester.should_receive(:create_object_with_conditions).and_return('flappie')
      @tester.create_object(@form_obj, :comments, true).should == 'flappie'
    end
  end

  context "get_partial_path" do
    it "generates the default partial name if no partial given" do
      result = @tester.get_partial_path(nil, :admin_comments)
      result.should == "admin_comment_fields"
    end
    it "uses the given partial name" do
      result = @tester.get_partial_path("comment_fields", :admin_comments)
      result.should == "comment_fields"
    end
  end

end
