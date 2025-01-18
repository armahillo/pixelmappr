# frozen_string_literal: true

require 'pixelmapper'

module Pixelmapper # rubocop:disable Metrics/ModuleLength
  describe Grid do
    let(:dimensions) { [8, 8] }
    let(:black) { Color.new('00', '00', '00', Color::OPAQUE, 'black') }
    let(:white) { Color.new('ff', 'ff', 'ff', Color::OPAQUE, 'white') }

    subject(:checkerboard) do
      board = described_class.new(*dimensions)
      64.times { |i| board << (i.even? ? white : black) }
      board
    end

    it 'instantiates a grid with a width' do
      expect(checkerboard.width).to eq(dimensions.first)
    end

    it 'instantiates the grid with height' do
      expect(checkerboard.height).to eq(dimensions.last)
    end

    describe '<<' do
      it 'adds the color to the data object' do
        expect do
          checkerboard << white
        end.to change(checkerboard.data, :count).by(1)
      end
    end

    describe '#manifest' do
      subject { checkerboard.manifest }

      it { is_expected.to be_instance_of(Hash) }
      it { is_expected.to eq({ 'black' => 32, 'white' => 32 }) }
    end

    describe '#legend' do
      subject(:legend) { checkerboard.legend }

      it 'contains an array of hashes of the colors used' do
        expect(legend).to contain_exactly({ name: 'empty', hexcode: '' },
                                          { name: 'white', hexcode: '#ffffff' },
                                          { name: 'black', hexcode: '#000000' })
      end

      it 'updates the legend when a new color is added' do
        expect do
          checkerboard << Color.new('aa', 'aa', 'aa', 'ff', 'Gray')
        end.to(change(checkerboard, :legend))
      end
    end

    describe '#to_a' do
      subject(:to_a) { checkerboard.to_a }

      it 'contains elements equal to the number of rows' do
        expect(to_a.count).to eq(checkerboard.height)
      end

      it 'contains elements within each row equal to the number of columns' do
        to_a.each do |row|
          expect(row.count).to eq(checkerboard.width)
        end
      end
    end

    describe '#to_s' do
      subject { checkerboard.to_s }
      let(:expected_output) do
        "1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
1 2 1 2 1 2 1 2
"
      end

      it { is_expected.to eq(expected_output) }

      context 'when there are many colors' do
        let(:checkerboard) do
          grid = described_class.new(7, 7)
          (11...46).each do |i|
            grid << Color.new(i.to_s, i.to_s, i.to_s)
          end
          grid
        end

        let(:expected_output) do
          "1 2 3 4 5 6 7
8 9 a b c d e
f g h i j k l
m n o p q r s
t u v w x y z
"
        end

        it { is_expected.to eq(expected_output) }
      end
    end

    describe '#to_html' do
      let(:html_output) { File.read('spec/data/checkerboard.html').chomp }

      subject { checkerboard.to_html }

      it { is_expected.to eq(html_output) }
    end

    describe '#export' do
      before do
        # Reset the export location
        ::FileUtils.rm_rf('./spec/export')
        ::FileUtils.mkdir('./spec/export')
      end

      it 'creates a file' do
        expect do
          checkerboard.export('spec/export/output.html')
        end.to change { File.exist?('spec/export/output.html') }.from(false).to(true)
      end

      it 'allows for a default filename' do
        allow(described_class).to receive(:default_filename).and_return('spec/export/output.html')
        expect do
          checkerboard.export
        end.to change { File.exist?('spec/export/output.html') }.from(false).to(true)
      end

      it 'appends html if that is not provided' do
        expect do
          checkerboard.export('spec/export/output')
        end.to change { File.exist?('spec/export/output.html') }.from(false).to(true)
      end
    end
  end
end
