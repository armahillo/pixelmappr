# frozen_string_literal: true

require 'pixelmapper'

module Pixelmapper
  describe Palette do
    let!(:standard_yml) { './spec/data/standard.yml' }
    let!(:alternate_yml) { './spec/data/alternate.yml' }
    let!(:standard_yml_colors) { YAML.load_file(standard_yml)['colors'] }

    let(:palette) { described_class.new }

    context 'with a loaded YAML config (standard)' do
      before do
        palette.load(standard_yml)
      end

      it 'creates Color objects when the YAML is loaded' do
        expect(palette.first.class).to eq(Color)
      end

      context 'when trying to access the color directly' do
        subject { palette.send(color_name) }

        context 'with a known color' do
          let(:color_name) { :black }
          let(:color) { Color.new(*standard_yml_colors[color_name.to_s]) }

          it { is_expected.to eq(color) }
        end

        context 'with an unknown color' do
          let(:color_name) { :foobar }

          it { is_expected.to be_nil }
        end
      end

      it 'can optionally use a fourth parameter to indicate alpha channel' do
        expect(palette.with_transparent.rgba[3]).to eq('88')
      end

      it 'returns `FF` by default if no alpha channel value is set explicitly' do
        expect(palette.black.rgba[3]).to eq('FF')
      end

      context 'when loading an additional palette' do
        it 'adds to the existing colors' do
          expect { palette.load(alternate_yml) }.to change { palette.colors.size }.by(1)
        end

        it 'appends an additional name to the name' do
          expect { palette.load(alternate_yml) }.to change(palette, :name).to('Standard, Alternate')
        end
      end
    end

    it 'infers a name from the filename if none is provided' do
      palette.load(alternate_yml)
      expect(palette.name).to eq('Alternate')
    end

    it 'can load a YAML config file, containing color profiles' do
      expect do
        palette.load(standard_yml)
      end.to change { palette.colors.size }.by(standard_yml_colors.size)
    end

    it 'sets the name of the palette' do
      palette.load(standard_yml)
      expect(palette.name).to eq('Standard')
    end

    it 'can receive a YAML file in the initializer and will automatically run load on it' do
      p = described_class.new(standard_yml)
      expect(p.colors.size).to eq(standard_yml_colors.size)
    end

    it 'responds to each, yielding an array of colors' do
      allow(palette).to receive(:colors).and_return({ 'a' => 0, 'b' => 1, 'c' => 2 })
      expect(palette.collect { |i| i }).to contain_exactly(0, 1, 2)
    end

    it 'has a `transparent` value, which returns `nil`' do
      expect(palette.transparent).to be_nil
    end
  end
end
