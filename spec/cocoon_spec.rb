require 'spec_helper'

describe Cocoon do
  class TestClass < ActionView::Base

  end

  subject {TestClass.new}

  it { should respond_to(:link_to_add_association) }
  it { should respond_to(:link_to_remove_association) }

  before(:each) do
    @tester = TestClass.new
    @post = Post.new
    @form_obj = stub(:object => @post, :object_name => @post.class.name)
  end


  context "link_to_add_association" do
    before(:each) do
      @tester.stub(:render_association).and_return('form<tag>')
    end

    context "without a block" do
      it "accepts a name" do
        result = @tester.link_to_add_association('add something', @form_obj, :comments)
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">add something</a>'
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_add_association('add something', @form_obj, :comments, {:class => 'something silly'})
        result.to_s.should == '<a href="#" class="something silly add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">add something</a>'
      end

      it "allows to explicitly hand the wanted partial" do
        @tester.unstub(:render_association)
        @tester.should_receive(:render_association).with(anything(), anything(), anything(), anything(), "shared/partial").and_return('partiallll')
        result = @tester.link_to_add_association('add something', @form_obj, :comments, :partial => "shared/partial")
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="partiallll" data-association="comment" data-associations="comments">add something</a>'
      end

      it "gives an opportunity to wrap/decorate created objects" do
        @tester.unstub(:render_association)
        @tester.should_receive(:render_association).with(anything(), anything(), kind_of(CommentDecorator), anything(), anything()).and_return('partiallll')
        @tester.link_to_add_association('add something', @form_obj, :comments, :wrap_object => Proc.new {|comment| CommentDecorator.new(comment) })
      end

      context "force non association create" do
        it "default it uses the association" do
          @tester.should_receive(:create_object).with(anything, :comments , false)
          result = @tester.link_to_add_association('add something', @form_obj, :comments)
          result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">add something</a>'
        end
        it "specifying false is the same as default: create object on association" do
          @tester.should_receive(:create_object).with(anything, :comments , false)
          result = @tester.link_to_add_association('add something', @form_obj, :comments, :force_non_association_create => false)
          result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">add something</a>'
        end
        it "specifying true will not create objects on association but using the conditions" do
          @tester.should_receive(:create_object).with(anything, :comments , true)
          result = @tester.link_to_add_association('add something', @form_obj, :comments, :force_non_association_create => true)
          result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">add something</a>'
        end

      end
    end

    context "with a block" do
      it "the block gives the link text" do
        result = @tester.link_to_add_association(@form_obj, :comments) do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">some long name</a>'
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_add_association(@form_obj, :comments, {:class => 'floppy disk'}) do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="floppy disk add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="comment" data-associations="comments">some long name</a>'
      end

      it "allows to explicitly hand the wanted partial" do
        @tester.unstub(:render_association)
        @tester.should_receive(:render_association).with(anything(), anything(), anything(), anything(), "shared/partial").and_return('partiallll')
        result = @tester.link_to_add_association( @form_obj, :comments, :class => 'floppy disk', :partial => "shared/partial") do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="floppy disk add_fields" data-association-insertion-template="partiallll" data-association="comment" data-associations="comments">some long name</a>'
      end
    end

    context "with an irregular plural" do
      it "uses the correct plural" do
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="person" data-associations="people">add something</a>'
      end
    end

    context "when using aliased association and class-name" do
      it "uses the correct name" do
        result = @tester.link_to_add_association('add something', @form_obj, :admin_comments)
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="admin_comment" data-associations="admin_comments">add something</a>'
      end
    end

    it "tttt" do
      @post.class.reflect_on_association(:people).klass.new.should be_a(Person)
    end

    context "with extra render-options for rendering the child relation" do
      it "uses the correct plural" do
        @tester.should_receive(:render_association).with(:people, @form_obj, anything, {:wrapper => 'inline'}, nil)
        result = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline'})
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tag&gt;" data-association="person" data-associations="people">add something</a>'
      end
    end

    context "passing locals to the partial" do
      it "when given: passes the locals to the partials" do
        @tester.unstub(:render_association)
        @form_obj.should_receive(:fields_for) { | association, new_object, options_hash, &block| block.call }
        @tester.should_receive(:render).with("person_fields", {:f=>nil, :dynamic=>true, :alfred=>"Judoka"}).and_return ("partiallll")
        result = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline', :locals => {:alfred => 'Judoka'}})
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="partiallll" data-association="person" data-associations="people">add something</a>'
      end
      it "if no locals are given it still works" do
        @tester.unstub(:render_association)
        @form_obj.should_receive(:fields_for) { | association, new_object, options_hash, &block| block.call }
        @tester.should_receive(:render).with("person_fields", {:f=>nil, :dynamic=>true}).and_return ("partiallll")
        result = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline'})
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="partiallll" data-association="person" data-associations="people">add something</a>'
      end
    end



    context "when using formtastic" do
      before(:each) do
        @tester.unstub(:render_association)
        @form_obj.stub(:semantic_fields_for).and_return('form<tagzzz>')
      end
      it "calls semantic_fields_for and not fields_for" do
        @form_obj.should_receive(:semantic_fields_for)
        @form_obj.should_receive(:fields_for).never
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tagzzz&gt;" data-association="person" data-associations="people">add something</a>'

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
      it "calls simple_fields_for and not fields_for" do
        @form_obj.should_receive(:simple_fields_for)
        @form_obj.should_receive(:fields_for).never
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association-insertion-template="form&lt;tagxxx&gt;" data-association="person" data-associations="people">add something</a>'

      end
    end

  end

  context "link_to_remove_association" do
    context "without a block" do
      it "accepts a name" do
        result = @tester.link_to_remove_association('remove something', @form_obj)
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"remove_fields dynamic\">remove something</a>"
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_remove_association('remove something', @form_obj, {:class => 'add_some_class', :'data-something' => 'bla'})
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"add_some_class remove_fields dynamic\" data-something=\"bla\">remove something</a>"
      end

    end

    context "with a block" do
      it "the block gives the name" do
        result = @tester.link_to_remove_association(@form_obj) do
          "remove some long name"
        end
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"remove_fields dynamic\">remove some long name</a>"
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_remove_association(@form_obj, {:class => 'add_some_class', :'data-something' => 'bla'}) do
          "remove some long name"
        end
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"add_some_class remove_fields dynamic\" data-something=\"bla\">remove some long name</a>"
      end
    end
  end

  context "create_object" do
    it "creates correct association with conditions" do
      @tester.should_not_receive(:create_object_with_conditions)
      result = @tester.create_object(@form_obj, :admin_comments)
      result.author.should == "Admin"
    end

    it "creates correct association for belongs_to associations" do
      result = @tester.create_object(stub(:object => Comment.new), :post)
      result.should be_a Post
    end

    it "raises an error if cannot reflect on association" do
      expect { @tester.create_object(stub(:object => Comment.new), :not_existing) }.to raise_error /association/i
    end

    it "creates an association if object responds to 'build_association' as singular" do
      object = Comment.new
      object.should_receive(:build_custom_item).and_return 'custom'
      @tester.create_object(stub(:object => object), :custom_item).should == 'custom'
    end

    it "creates an association if object responds to 'build_association' as plural" do
      object = Comment.new
      object.should_receive(:build_custom_item).and_return 'custom'
      @tester.create_object(stub(:object => object), :custom_items).should == 'custom'
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
