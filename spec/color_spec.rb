# frozen_string_literal: true

require 'pixelmapper'
require 'yaml'

module Pixelmapper
  describe Color do
    let(:pink16_rgb) { %w[F0 5F A5 FF] }
    let(:pink_rgb) { [240, 95, 165, 255] }
    let(:pink) { described_class.new(*pink16_rgb) }

    let!(:palette) { Palette.new('./spec/data/perler.yml') }

    # Perler color pairings
    let(:colors) do
      {
        black: palette.black,
        cheddar: palette.cheddar, # rgb(241, 170, 12) -> lab(74.5, 15.49, 76.52)
        gold: described_class.new('d4', 'a0', '17'), # rgb(212, 160, 23) -> lab(68.9, 8.38, 69.12)
        dark_blue: palette.dark_blue, # rgb(43,63,135) -> lab(28.95, 17.29, -42.75)
        cornflowerblue: described_class.new('15', '1b', '8d'), # rgb(21, 27, 141) -> lab(19.5, 40.47, -62.01)
        pastel_green: palette.pastel_green, # rgb(118, 200, 130) -> lab(74.04, -39.72, 27.39)
        seagreen: described_class.new('2e', '8b', '57'), # rgb(46,139,87) -> lab(51.53, -39.72, 20.05)
        warm_black: described_class.new('05', '00', '00')
      }
    end

    # Calibrating values
    # red: 'FF', '00', '00' -> lab(53.24, 80.09, 67.2)
    # green: '00', 'FF', '00' -> lab(87.73, -86.18, 83.18)
    # blue: '00', '00', 'FF' -> lab(32.3, 79.19, -107.86)

    describe 'Methods >' do
      it 'to_hex' do
        expect(pink.to_hex).to match_array(pink16_rgb)
      end

      it 'to_int' do
        expect(pink.to_int).to match_array(pink_rgb)
      end
    end

    describe 'Calibrations' do
      YAML.load_file('./spec/data/calibration.yml').each do |color_name, data|
        describe "#{color_name} >" do
          let(:color) { described_class.new(*data['hex'], color_name) }

          describe '#to_hex' do
            subject { color.to_hex }

            it { is_expected.to match_array(data['hex']) }
          end

          describe '#to_rgb' do
            subject { color.to_rgb }

            it { is_expected.to match_array(data['rgb']) }
          end

          describe '#xyz' do
            subject { color.to_xyz }

            it { is_expected.to match_array(data['xyz'].map { |v| v.round(2) }) }
          end

          describe '#lab' do
            subject { color.to_lab }

            it { is_expected.to match_array(data['lab'].map { |v| v.round(2) }) }
          end
        end
      end
    end

    %i[deltaE76 deltaE94].each do |algorithm|
      describe ".#{algorithm}" do
        it 'returns a float in distance' do
          expect(described_class.send(algorithm, colors[:cheddar], colors[:gold]).class).to eq(Float)
        end

        it 'returns lower values for similar colors' do
          cheddar_gold_distance = described_class.send(algorithm, colors[:cheddar], colors[:gold])
          cornflowerblue_gold_distance = described_class.send(algorithm, colors[:cornflowerblue], colors[:gold])
          expect(cheddar_gold_distance).to be < cornflowerblue_gold_distance
        end

        describe 'correctly matches within color pairings' do
          context 'when gold matches to cheddar' do
            subject { described_class.send(algorithm, colors[:cheddar], colors[:gold]) }

            it { is_expected.to be < described_class.send(algorithm, colors[:cheddar], colors[:cornflowerblue]) }
            it { is_expected.to be < described_class.send(algorithm, colors[:cheddar], colors[:seagreen]) }
          end

          context 'when darkblue matches to cornflowerblue' do
            subject { described_class.send(algorithm, colors[:dark_blue], colors[:cornflowerblue]) }

            it { is_expected.to be < described_class.send(algorithm, colors[:dark_blue], colors[:gold]) }
            it { is_expected.to be < described_class.send(algorithm, colors[:dark_blue], colors[:seagreen]) }
          end

          context 'when pastel_green matches to seagreen' do
            subject { described_class.send(algorithm, colors[:pastel_green], colors[:seagreen]) }

            it { is_expected.to be < described_class.send(algorithm, colors[:pastel_green], colors[:gold]) }
            it { is_expected.to be < described_class.send(algorithm, colors[:pastel_green], colors[:dark_blue]) }
          end
        end
      end
    end

    describe '#closest_match' do
      it 'finds the closest match, given a list' do
        expect(colors[:cheddar].closest_match(colors[:gold], colors[:cornflowerblue],
                                              colors[:seagreen])).to eq(colors[:gold])
      end

      it 'is able to match black, which sometimes maps incorrectly' do
        expect(colors[:warm_black].closest_match(colors[:black], colors[:dark_blue],
                                                 colors[:seagreen])).to eq(colors[:black])
      end
    end
  end
end
