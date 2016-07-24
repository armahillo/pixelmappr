require 'pixelmapper'

module Pixelmapper

describe "Color" do

  let(:pink16_rgb) { ["F0","5F","A5", "FF"] }
  let(:pink_rgb) { [240, 95, 165, 255] }
  let(:pink) { Color.new(*pink16_rgb) }
  
  # Perler Color pairings
  let(:cheddar) { Color.new("fa","c8","55","ff", "cheddar") }
  let(:gold) { Color.new("d4","a0","17") }
  
  let(:dark_blue) { Color.new("23","50","91","ff", "dark blue") }
  let(:cornflowerblue) { Color.new("15","1b","8d") }
  
  let(:pastel_green) { Color.new("87","d2","91","ff", "pastel green") }
  let(:seagreen) { Color.new("2e","8b","57") }  
  
  
  describe "Methods > " do
    it "to_hex" do
      expect(pink).to respond_to(:to_hex)
      expect(pink.to_hex).to match_array(pink16_rgb)
    end
    it "to_int" do
      expect(pink).to respond_to(:to_int)
      expect(pink.to_int).to match_array(pink_rgb)
    end
  end
  
  context "representation" do
    it "can show a hexadecimal string" do
      expect(pink.rgba).to match_array(pink16_rgb)
    end
    
    it "can show an integer value" do
      expect(pink.to_int).to match_array(pink_rgb)
    end
  end
  
  context "when matching a color" do
  
    it "finds the closest match, given a list" do
      expect(cheddar.closest_match(gold,cornflowerblue,seagreen)).to eq(gold)    
    end
    
    context "with the 1976 algorithm" do
      it "returns a float in distance" do
        expect(Color.deltaE76(cheddar,gold).class).to eq(Float)
      end
      it "returns lower values for similar colors" do
        cheddar_gold_distance = Color.deltaE76(cheddar,gold)
        cornflowerblue_gold_distance = Color.deltaE76(cornflowerblue,gold)
        expect(cheddar_gold_distance).to be < cornflowerblue_gold_distance
      end
      describe "correctly matches within color pairings" do
      
        it "gold with cheddar" do
          best_match = Color.deltaE76(cheddar,gold)
          bad_match_1 = Color.deltaE76(cheddar,cornflowerblue)
          bad_match_2 = Color.deltaE76(cheddar,seagreen)
        
          expect(best_match).to be < bad_match_1
          expect(best_match).to be < bad_match_2
        end
        
        it "darkblue with cornflowerblue" do
          best_match = Color.deltaE76(dark_blue, cornflowerblue)
          bad_match_1 = Color.deltaE76(dark_blue, gold)
          bad_match_2 = Color.deltaE76(dark_blue, seagreen)
          
          expect(best_match).to be < bad_match_1
          expect(best_match).to be < bad_match_2
        end
        
        it "pastel_green with seagreen" do
          best_match = Color.deltaE76(pastel_green, seagreen)
          bad_match_1 = Color.deltaE76(pastel_green, gold)
          bad_match_2 = Color.deltaE76(pastel_green, dark_blue)
          
          expect(best_match).to be < bad_match_1
          expect(best_match).to be < bad_match_2
        end
      end
    end
    
    context "with the 1994 algorithm" do
      it "returns a float in distance" do
        expect(Color.deltaE94(cheddar,gold).class).to eq(Float)
      end
      it "returns lower values for similar colors" do
        cheddar_gold_distance = Color.deltaE94(cheddar,gold)
        cornflowerblue_gold_distance = Color.deltaE94(cornflowerblue,gold)
        expect(cheddar_gold_distance).to be < cornflowerblue_gold_distance
      end
      
      
      describe "correctly matches within color pairings" do
        it "gold with cheddar" do
          best_match = Color.deltaE94(cheddar,gold)
          bad_match_1 = Color.deltaE94(cheddar,cornflowerblue)
          bad_match_2 = Color.deltaE94(cheddar,seagreen)
        
          expect(best_match).to be < bad_match_1
          expect(best_match).to be < bad_match_2
        end
        
        it "darkblue with cornflowerblue" do
          best_match = Color.deltaE94(dark_blue, cornflowerblue)
          bad_match_1 = Color.deltaE94(dark_blue, gold)
          bad_match_2 = Color.deltaE94(dark_blue, seagreen)
          
          expect(best_match).to be < bad_match_1
          expect(best_match).to be < bad_match_2
        end
        
        it "pastel_green with seagreen" do
          best_match = Color.deltaE94(pastel_green, seagreen)
          bad_match_1 = Color.deltaE94(pastel_green, gold)
          bad_match_2 = Color.deltaE94(pastel_green, dark_blue)
          
          expect(best_match).to be < bad_match_1
          expect(best_match).to be < bad_match_2
        end
      end
    end

  end

end

end
