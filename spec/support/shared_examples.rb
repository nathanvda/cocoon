# -*- encoding : utf-8 -*-
shared_examples_for "a correctly rendered add link" do |options|
  context "the rendered link" do
    before do
      default_options = {
          href: '#',
          class: 'add_fields',
          template: "form<tag>",
          association: 'comment',
          associations: 'comments',
          text: 'add something',
          extra_attributes: {}
      }
      @options = default_options.merge options

      doc = Nokogiri::HTML(@html)
      @link = doc.at('a')
    end
    it 'has a correct href' do
      @link.attribute('href').value.should == @options[:href]
    end
    it 'has a correct class' do
      @link.attribute('class').value.should == @options[:class]
    end
    it 'has a correct template' do
      @link.attribute('data-association-insertion-template').value.should == @options[:template]
    end
    it 'has a correct associations' do
      @link.attribute('data-association').value.should == @options[:association]
      @link.attribute('data-associations').value.should == @options[:associations]
    end
    it 'has the correct text' do
      @link.text.should == @options[:text]
    end
    it 'sets extra attributes correctly' do
      @options[:extra_attributes].each do |key, value|
        @link.attribute(key).value.should == value
      end
    end

  end
end

shared_examples_for "a correctly rendered remove link" do |options|
  context "the rendered link" do
    before do
      default_options = {
          href: '#',
          class: 'remove_fields dynamic',
          text: 'remove something',
          extra_attributes: {}
      }
      @options = default_options.merge options

      doc = Nokogiri::HTML(@html)
      @link = doc.at('a')
    end
    it 'has a correct href' do
      @link.attribute('href').value.should == @options[:href]
    end
    it 'has a correct class' do
      @link.attribute('class').value.should == @options[:class]
    end
    it 'has the correct text' do
      @link.text.should == @options[:text]
    end
    it 'sets extra attributes correctly' do
      @options[:extra_attributes].each do |key, value|
        @link.attribute(key).value.should == value
      end
    end
  end
end
