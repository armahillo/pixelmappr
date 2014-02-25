require 'perlerbeads'

module Perlerbeads

describe "Grid" do

  let(:grid) { Grid.new(16,16) }

  describe "Constructor" do
    it "instantiates a grid with a width and height" do
    end
  end

  describe "Attributes > " do
    it "width" do
      expect(grid).to respond_to(:width)
    end
    it "height" do
      expect(grid).to respond_to(:height)
    end
    
  end
  describe "Reports > " do
    describe "Bead Manifest" do
      it "exists" do
        expect(grid).to respond_to(:bead_manifest)
      end
      it "prints a bead manifest" do
        pending "needs to compare to output"
      end
    end
    
    describe "Grid Dump" do
      it "exists" do
        expect(grid).to respond_to(:grid)
      end
      it "prints a grid with a legend" do
        pending "needs to compare to output"
      end
    end
    
    describe "HTML Output" do
      it "exists" do
        expect(grid).to respond_to(:html)
      end
      it "prints an HTML representation of the image" do
      
      end
    end
    
  end
end

end
