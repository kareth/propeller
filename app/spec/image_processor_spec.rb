require 'propeller'
require 'propeller/image_processor'

describe Propeller::ImageProcessor do
  let(:propeller){ Propeller.new [] }
  let(:test_file){ File.expand_path "assets/test.jpg", Pathname(__FILE__).dirname.realpath }

  describe "#process" do
    it "should create new file for processed file" do
      propeller.process_image test_file
      expect(File.exists?(propeller.current_image)).to equal(true)
    end

    it "should not delete original image file"
    it "should not change original image file"
    it "should process image correctly with default options"
    it "should resize image correctly"
    it "should position image correctly"
    it "should output file with correct dimensions"
  end
end
