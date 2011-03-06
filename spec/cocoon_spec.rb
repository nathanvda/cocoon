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
      @tester.stub(:render_association).and_return('form')
    end

    it "should accept a name without a block" do
      result = @tester.link_to_add_association('add something', @form_obj, :comments)
      result.to_s.should == '<div id="comment_fields_template" style="display:none;">form</div><a href="#" class="add_fields" data-association="comment">add something</a>'
    end

    it "should work with a block" do
      result = @tester.link_to_add_association(@form_obj, :comments) do
        "some long name"
      end
      result.to_s.should == '<div id="comment_fields_template" style="display:none;">form</div><a href="#" class="add_fields" data-association="comment">some long name</a>'
    end
  end

end