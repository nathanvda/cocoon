require 'spec_helper'

describe "Navigation" do
#  include Capybara
  
  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end
end
