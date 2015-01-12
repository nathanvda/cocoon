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
      expect(@link.attribute('href').value).to eq(@options[:href])
    end
    it 'has a correct class' do
      expect(@link.attribute('class').value).to eq(@options[:class])
    end
    it 'has a correct template' do
      expect(@link.attribute('data-association-insertion-template').value).to eq(@options[:template])
    end
    it 'has a correct associations' do
      expect(@link.attribute('data-association').value).to eq(@options[:association])
      expect(@link.attribute('data-associations').value).to eq(@options[:associations])
    end
    it 'has the correct text' do
      expect(@link.text).to eq(@options[:text])
    end
    it 'sets extra attributes correctly' do
      @options[:extra_attributes].each do |key, value|
        expect(@link.attribute(key).value).to eq(value)
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
      expect(@link.attribute('href').value).to eq(@options[:href])
    end
    it 'has a correct class' do
      expect(@link.attribute('class').value).to eq(@options[:class])
    end
    it 'has the correct text' do
      expect(@link.text).to eq(@options[:text])
    end
    it 'sets extra attributes correctly' do
      @options[:extra_attributes].each do |key, value|
        expect(@link.attribute(key).value).to eq(value)
      end
    end
  end
end
