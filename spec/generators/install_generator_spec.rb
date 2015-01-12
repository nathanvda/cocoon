require 'spec_helper'

require 'generator_spec/test_case'
require 'generators/cocoon/install/install_generator'

describe Cocoon::Generators::InstallGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  context "in rails 3.0" do
    context "with no arguments" do
      before(:each) do
        allow(::Rails).to receive(:version) { '3.0.8' }
        prepare_destination
        run_generator
      end

      it "stubs the version correctly" do
        expect(::Rails.version[0..2]).to eq("3.0")
      end

      it "stubs the version correctly" do
        test_version = (::Rails.version[0..2].to_f >= 3.1)
        expect(test_version).to be_falsey
      end

      it "copies cocoon.js to the correct folder" do
        assert_file "public/javascripts/cocoon.js"
      end
    end
  end

  context "in rails 3.1" do
    context "with no arguments" do
      before(:each) do
        allow(::Rails).to receive(:version) { '3.1.0' }
        prepare_destination
        run_generator
      end

      it "does not copy cocoon.js" do
        assert_no_file "public/javascripts/cocoon.js"
      end
    end
  end

end
