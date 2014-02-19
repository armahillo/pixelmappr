require 'color'

describe "Color" do

  let!(:pink16_rgb) { ["F0","5F","A5", "FF"] }
  let!(:pink32_rgb) { ["F0F0", "5F5F", "A5A5", "FFFF"] }
  let!(:pink_rgb) { [61680, 24415, 42405, 65535] }
  let!(:pink) { Color.new(*pink16_rgb) }
  
  # This group should be similar to one another, with gold and orange slightly closer
  let(:gold) { Color.new("d4","a0","17") }
  let(:yellow) { Color.new("ff","ff","00") }
  let(:orange) { Color.new("f8","7a","17") }
  
  # Blue group
  let(:blue) { Color.new("00","00","ff") }
  let(:deepskyblue) { Color.new("3b","b9","ff") }
  let(:cornflowerblue) { Color.new("15","1b","8d") }
  
  # Green group
  let(:forestgreen) { Color.new("4e","92","58") }
  let(:lawngreen) { Color.new("87","f7","17") }
  let(:seagreen) { Color.new("2e","8b","57") }
  
  describe "Methods > " do
    it "to_hex" do
      expect(pink).to respond_to(:to_hex)
      expect(pink.to_hex).to match_array(pink32_rgb)
    end
    it "to_int" do
      expect(pink).to respond_to(:to_int)
      expect(pink.to_int).to match_array(pink_rgb)
    end
  end
  
  context "representation" do
    it "can show a hexadecimal string" do
      expect {
        pink.to_rgb
      }.to match_array(pink32_rgb)
    end
    
    it "can show an integer value" do
      
    end
  end
  
  context "with 16 bit color values" do
    
  end
  
  context "with 32 bit color values" do
  
  end
  
  context "when matching a color" do
  
    before(:each) do
      @yellows = [gold,yellow,orange]
      @blues = [blue,deepskyblue,cornflowerblue]
      @greens = [forestgreen,lawngreen,seagreen]
      
      # Find the max distance within each color group
      @max_internal_yellow = [Color.deltaE94(gold,yellow), Color.deltaE94(gold,orange), Color.deltaE94(yellow,orange)].max
      @max_internal_blue = [Color.deltaE94(blue,deepskyblue), Color.deltaE94(blue,cornflowerblue), Color.deltaE94(deepskyblue, cornflowerblue)].max
      @max_internal_green = [Color.deltaE94(forestgreen, lawngreen), Color.deltaE94(forestgreen,seagreen), Color.deltaE94(lawngreen,seagreen)].max
    end
    
    context "with the 1976 algorithm" do
      it "returns a float in distance" do
        expect(Color.deltaE76(blue,deepskyblue).class).to eq(Float)
      end
      it "returns lower values for similar colors" do
        orange_gold_distance = Color.deltaE76(orange,gold)
        orange_blue_distance = Color.deltaE76(orange,blue)
        expect(orange_gold_distance).to be < orange_blue_distance
      end
      it "has some level of precision" do
        orange_gold_distance = Color.deltaE76(orange,gold)
        yellow_gold_distance = Color.deltaE76(yellow,gold)
        expect(orange_gold_distance).to be < yellow_gold_distance
      end
      it "correctly matches within color groups" do
        # All non-group colors should have a distance greater than the max distance
        (@yellows + @blues).each do |ng|
          @greens.each do |g|
            d = Color.deltaE76(ng,g)
            expect(d).to be > @max_internal_green
          end
        end
        (@yellows + @greens).each do |nb|
          @blues.each do |b|
            expect(Color.deltaE76(nb,b)).to be > @max_internal_blue
          end
        end
        (@blues + @greens).each do |ny|
          @yellows.each do |y|
            expect(Color.deltaE76(ny,y)).to be > @max_internal_yellow
          end
        end
      end
    end
    
    context "with the 1994 algorithm" do
      it "returns a float in distance" do
        expect(Color.deltaE94(blue,deepskyblue).class).to eq(Float)
      end
      it "returns lower values for similar colors" do
        orange_gold_distance = Color.deltaE94(orange,gold)
        orange_blue_distance = Color.deltaE94(orange,blue)
        expect(orange_gold_distance).to be < orange_blue_distance
      end
      it "has some level of precision" do
        orange_gold_distance = Color.deltaE94(orange,gold)
        yellow_gold_distance = Color.deltaE94(yellow,gold)
        expect(orange_gold_distance).to be < yellow_gold_distance
      end
      it "finds the closest match, given a list" do
        puts @yellows.first.inspect
        puts @yellows.first.closest_match(*(@blues + @greens),@yellows[1],@yellows[2]).inspect
      end
      it "correctly matches within color groups" do
        # All non-group colors should have a distance greater than the max distance
        (@yellows + @blues).each do |ng|
          @greens.each do |g|
            d = Color.deltaE94(ng,g)
            expect(d).to be > @max_internal_green
          end
        end
        (@yellows + @greens).each do |nb|
          @blues.each do |b|
            expect(Color.deltaE94(nb,b)).to be > @max_internal_blue
          end
        end
        (@blues + @greens).each do |ny|
          @yellows.each do |y|
            expect(Color.deltaE94(ny,y)).to be > @max_internal_yellow
          end
        end
      end
    end

  end

end
