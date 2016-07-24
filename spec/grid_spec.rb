require 'pixelmapper'

module Pixelmapper

describe "Grid" do

  let(:html_output) { File.read("spec/data/checkerboard.html").chomp }
  let(:grid) { Grid.new(8,8) }
  let(:black) { Color.new("00","00","00","ff","black") }
  let(:white) { Color.new("ff","ff","ff","ff","white") }

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
          grid << white
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
      end
      it "contains the count for each color used" do
        manifest = @checkerboard.manifest
        expect(manifest.keys).to match_array([black.name,white.name])
        expect(manifest.values).to match_array([32,32])
      end
    end
    describe "legend" do
      it "exists" do
        expect(grid).to respond_to(:legend)
      end
      it "returns an array of hashes" do
        expect(@checkerboard.legend.class).to eq(Array)
        expect(@checkerboard.legend[0].class).to eq(Hash)
      end
      it "enumerates the colors to indices" do
        legend = @checkerboard.legend
        expect(legend[0][:name]).to eq("empty")
        expect(legend[1][:hexcode]).to eq("#ffffff")
        expect(legend[2][:name]).to eq("black")
      end
      it "updates the legend when a new color is added" do
        expect {
          @checkerboard << Color.new("aa","aa","aa","ff","Gray")
        }.to change{@checkerboard.legend}
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
      around(:each) do
        ::FileUtils.rm_rf("./spec/export")
        ::FileUtils.mkdir("./spec/export")
      end
      it "exists" do
        expect(grid).to respond_to(:export)
      end
      it "creates a file" do
        expect {
          grid.export('spec/export/output.html')
        }.to change{File.exists?('spec/export/output.html')}.from(false).to(true)
      end
      it "allows for a default filename" do
        allow(Grid).to_receive(:default_filename).and_return("spec/export/output.html")
        expect {
          grid.export
        }.to change{File.exists?('spec/export/output.html')}.from(false).to(true)
      end
      it "appends html if that is not provided" do
        expect {
          grid.export('spec/export/output')
        }.to change{File.exists?('spec/export/output.html')}.from(false).to(true)
      end
    end
  end
  
end

end
