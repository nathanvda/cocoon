require 'spec_helper'

describe Cocoon do
  class TestClass < ActionView::Base

  end

  subject {TestClass.new}

  it { should respond_to(:link_to_add_association) }
  it { should respond_to(:link_to_remove_association) }

  context "link_to_add_association" do
    before(:each) do
      @tester = TestClass.new
      @post = Post.new
      @form_obj = stub(:object => @post)
      @tester.stub(:render_association).and_return('form<tag>')
    end

    context "without a block" do
      it "should accept a name" do
        result = @tester.link_to_add_association('add something', @form_obj, :comments)
        result.to_s.should == '<a href="#" class="add_fields" data-association="comment" data-associations="comments" data-template="form&amp;lt;tag&amp;gt;">add something</a>'
      end

      it "should accept html options and pass them to link_to" do
        result = @tester.link_to_add_association('add something', @form_obj, :comments, {:class => 'something silly'})
        result.to_s.should == '<a href="#" class="something silly add_fields" data-association="comment" data-associations="comments" data-template="form&amp;lt;tag&amp;gt;">add something</a>'
      end
    end

    context "with a block" do
      it "the block gives the link text" do
        result = @tester.link_to_add_association(@form_obj, :comments) do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="add_fields" data-association="comment" data-associations="comments" data-template="form&amp;lt;tag&amp;gt;">some long name</a>'
      end

      it "should accept html options and pass them to link_to" do
        result = @tester.link_to_add_association(@form_obj, :comments, {:class => 'floppy disk'}) do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="floppy disk add_fields" data-association="comment" data-associations="comments" data-template="form&amp;lt;tag&amp;gt;">some long name</a>'
      end

    end

    context "with an irregular plural" do
      it "should use the correct plural" do
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association="person" data-associations="people" data-template="form&amp;lt;tag&amp;gt;">add something</a>'
      end

    end

  end

  context "link_to_remove_association" do
    before(:each) do
      @tester = TestClass.new
      @post = Post.new
      @form_obj = stub(:object => @post, :object_name => @post.class.name)
    end

    context  "without a block" do
      it "should accept a name" do
        result = @tester.link_to_remove_association('remove something', @form_obj)
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"remove_fields dynamic\">remove something</a>"
      end

      it "should accept html options and pass them to link_to" do
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

      it "should accept html options and pass them to link_to" do
        result = @tester.link_to_remove_association(@form_obj, {:class => 'add_some_class', :'data-something' => 'bla'}) do
          "remove some long name"
        end
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"add_some_class remove_fields dynamic\" data-something=\"bla\">remove some long name</a>"
      end
    end
  end

end
