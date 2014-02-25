require 'perlerbeads'

module Perlerbeads

describe "Perler" do

  let!(:source_image) { "spec/data/plumber.gif" }
  let!(:test_img) { Perler.new(source_image) }
  
  describe "Constructor" do
    it "instantiates with a valid image file" do
      p = Perler.new(source_image)
      expect(p).to be_instance_of(Perler)
    end
    it "fails gracefully if the image path is invalid" do
      expect {
       Perler.new("nonexistant.image")
      }.to raise_error
    end
  end

  describe "Attributes > " do
    describe "dimensions > " do
      it "rows" do
        expect(test_img).to respond_to(:rows)
        expect(test_img.rows).to eq(16)
      end
      it "columns" do
        expect(test_img).to respond_to(:columns)
        expect(test_img.columns).to eq(12)
      end
      it "total pixels" do
        expect(test_img).to respond_to(:total_pixels)
        expect(test_img.total_pixels).to eq(192)
      end
      it "total beads" do
        expect(test_img).to respond_to(:total_beads)
        expect(test_img.total_beads).to eq(143)
      end
    end
  end
end

end
