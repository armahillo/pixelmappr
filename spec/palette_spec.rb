require 'pixelmapper'

module Pixelmapper

describe "Palette" do
	let!(:standard_yml) { './spec/data/standard.yml' }
    let!(:alternate_yml) { './spec/data/alternate.yml' }
    let!(:standard_yml_colors) { YAML.load_file(standard_yml)["colors"] }

    context "With a YAML config loaded" do
      before(:each) do
      	@palette = Palette.new 
      	@palette.load(standard_yml)
      end

      it "creates Color objects when the YAML is loaded" do
		expect(@palette.first.class).to eq(Color)
	  end
  
	  it "can look up colors using method_missing" do
		expect(@palette.black.to_s).to eq("#010101")
		expect(@palette.foobar).to be_nil
	  end

	  it "can optionally use a fourth parameter to indicate alpha channel" do
	  	expect(@palette.with_transparent.rgba[3]).to eq("88")
	  end

	  it "returns `FF` by default if no alpha channel value is set explicitly" do
	  	expect(@palette.black.rgba[3]).to eq("FF")
	  end

	  context "when loading an additional palette" do
        it "adds to the existing colors" do
        	expect { @palette.load(alternate_yml) }.to change{@palette.colors.size}.by(1)
        end

        it "appends an additional name to the name" do
        	expect { @palette.load(alternate_yml) }.to change{@palette.name}.to("Standard, Alternate")
        end
	  end
    end

    it "infers a name from the filename if none is provided" do
    	p = Palette.new
    	p.load('./spec/data/alternate.yml')
    	expect(p.name).to eq("Alternate")
    end


	it "can load a YAML config file, containing color profiles" do
      p = Palette.new
      expect(p).to be_respond_to(:load)
      expect { 
        p.load("./spec/data/standard.yml")
      }.to change{p.colors.size}.by(standard_yml_colors.size)

      expect(p.name).to eq("Standard")
	end

	it "can receive a YAML file in the initializer and will automatically run load on it" do
		p = Palette.new(standard_yml)
		expect(p.colors.size).to eq(standard_yml_colors.size)
	end

	it "responds to each, yielding an array of colors" do
		allow_any_instance_of(Palette).to receive(:colors).and_return({'a' => 0,'b' => 1,'c' => 2})
		p = Palette.new
		expect(p.collect { |i| i }).to match_array([0,1,2])
	end

	it "has a `transparent` value, which returns `nil`" do
		p = Palette.new
		expect(p.transparent).to be_nil
	end
end

end