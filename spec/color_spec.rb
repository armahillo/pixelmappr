require 'pixelmapper'
require 'yaml'

module Pixelmapper

  describe "Color" do
    let(:pink16_rgb) { ["F0","5F","A5", "FF"] }
    let(:pink_rgb) { [240, 95, 165, 255] }
    let(:pink) { Color.new(*pink16_rgb) }

    let!(:palette) { Palette.new('./spec/data/perler.yml') }

    # Perler Color pairings
    let(:cheddar) { palette.cheddar } # # rgb(241, 170, 12) -> lab(74.5, 15.49, 76.52)
    let(:gold) { Color.new("d4","a0","17") } # rgb(212, 160, 23) -> lab(68.9, 8.38, 69.12)

    let(:dark_blue) { palette.dark_blue } # rgb(43,63,135) -> lab(28.95, 17.29, -42.75)
    let(:cornflowerblue) { Color.new("15","1b","8d") } # rgb(21, 27, 141) -> lab(19.5, 40.47, -62.01)

    let(:pastel_green) { palette.pastel_green } # rgb(118, 200, 130) -> lab(74.04, -39.72, 27.39)
    let(:seagreen) { Color.new("2e","8b","57") }  # rgb(46,139,87) -> lab(51.53, -39.72, 20.05)

    # Calibrating values
    # red: 'FF', '00', '00' -> lab(53.24, 80.09, 67.2)
    # green: '00', 'FF', '00' -> lab(87.73, -86.18, 83.18)
    # blue: '00', '00', 'FF' -> lab(32.3, 79.19, -107.86)

    describe "Methods > " do
      it "to_hex" do
        expect(pink.to_hex).to match_array(pink16_rgb)
      end
      it "to_int" do
        expect(pink.to_int).to match_array(pink_rgb)
      end
    end

    describe "Calibrations" do
      YAML.load_file('./spec/data/calibration.yml').each do |color_name, data|
        describe "#{color_name} >" do
          let(:color) { Color.new(*data['hex'], color_name) }

          describe "#to_hex" do
            subject { color.to_hex }

            it { is_expected.to match_array(data['hex']) }
          end

          describe "#to_rgb" do
            subject { color.to_rgb }

            it { is_expected.to match_array(data['rgb']) }
          end

          describe "#xyz" do
            subject { color.to_xyz }

            it { is_expected.to match_array(data['xyz'].map { |v| v.round(2) }) }
          end

          describe "#lab" do
            subject { color.to_lab }

            it { is_expected.to match_array(data['lab'].map { |v| v.round(2) }) }
          end

        end
      end

      context "RGB (hex) -> RGB (int)" do

      end

      context "RGB -> XYZ" do

      end

      context "XYZ -> LAB" do
      end
    end

    context "when matching a color" do

      #pending "it is able to match black (black sometimes maps incorrectly)" do
      #end

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
