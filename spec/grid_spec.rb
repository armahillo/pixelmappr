require 'perlerbeads'

module Perlerbeads

describe "Grid" do

  let(:html_output) { file = File.open("spec/data/checkerboard.html", "r")
                      contents = file.read.chomp
                      file.close
                      return contents }
  let(:grid) { Grid.new(8,8) }
  let(:black) { Color.new("00","00","00") }
  let(:white) { Color.new("ff","ff","ff") }

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
  
  describe "Methods > " do
    before(:each) do
      @checkerboard = grid.clone
      64.times { |i| @checkerboard << (i%2==0 ? white : black) }
    end
    describe "<<" do
      it "exists" do
        expect(grid).to respond_to(:<<)
      end
      it "adds the color to the data object" do
        expect {
          grid << Color.new("ff","ff","ff")
        }.to change(grid.data, :count).by(1)
      end
    end
    describe "manifest" do
      
      it "exists" do
        expect(grid).to respond_to(:manifest)
      end      
      it "returns a hash" do
        manifest = @checkerboard.manifest
        expect(manifest.class).to eq(Hash)
        expect(manifest.keys).to match_array([black.to_s,white.to_s])
        expect(manifest.values).to match_array([32,32])
      end
    end
    describe "legend" do
      it "exists" do
        expect(grid).to respond_to(:legend)
      end
      it "returns a hash" do
        expect(@checkerboard.legend.class).to eq(Hash)
      end
      
    end
    describe "to_a" do
      it "exists" do
        expect(grid).to respond_to(:to_a)
      end
      it "returns a 2D array" do
        g = @checkerboard.to_a
        expect(g.count).to eq(grid.height)
        expect(g.first.count).to eq(grid.width)
      end
    end
    describe "to_s" do
      it "returns a string" do
        expect(@checkerboard.to_s.class).to eq(String)
      end
      it "returns a grid with a legend" do
expected_output = "1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
1 2 1 2 1 2 1 2 
"
        expect(@checkerboard.to_s).to eq(expected_output)
      end
      it "goes into alphanumerics above 9" do
expected_output = "1 2 3 4 5 6 7 
8 9 a b c d e 
f g h i j k l 
m n o p q r s 
t u v w x y z 
"      
        g = Grid.new(7,7)
        (11...46).each do |i|
          g << Color.new("#{i}","#{i}","#{i}")
        end
        expect(g.to_s).to eq(expected_output)
      end
    end
    
    describe "to_html" do
      it "exists" do
        expect(grid).to respond_to(:to_html)
      end
      it "prints an HTML representation of the image" do
        expect(@checkerboard.to_html).to eq(html_output)
      end
    end
    
    describe "export" do
      it "exists" do
        expect(grid).to respond_to(:export)
      end
      it "creates a file" do
        pending("How to check for files created?")
      end
    end
  end
  
end

end
