# frozen_string_literal: true

require 'exporter'
require 'timecop'


describe Exporter do
  before do
    # Reset the export location
    ::FileUtils.rm_rf('./spec/export')
    ::FileUtils.mkdir('./spec/export')
  end

  let(:good_path) { './spec/export' }
  let(:good_filename) { 'output.txt' }
  let(:filename_with_path) { File.join(good_path, good_filename) }

  subject(:valid_object) { described_class.new(filename_with_path) }

  describe ".new" do
    context "when a block is passed in that modifies the dir and filename" do
      let(:different_dir) { 'different' }
      let(:different_filename) { 'different' }

      subject(:changed_filepath) {
        described_class.new(filename_with_path) do |dir, filename|
          [different_dir, different_filename]
        end
      }

      it "can change the dir" do
        expect(changed_filepath.dir).to eq(different_dir)
      end

      it "can change the filename" do
        expect(changed_filepath.filename).to eq(different_filename)
      end
    end
  end

  describe "#dir" do
    subject { valid_object.dir }

    it { is_expected.to eq(good_path) }
  end

  describe "#filename" do
    context "with a provided filename" do
      subject { valid_object.filename }

      it { is_expected.to eq(good_filename) }
    end

    context "when nothing is provided" do
      subject { described_class.new }

      it "uses the default dir" do
        expect(subject.dir).to eq(described_class::DEFAULT_DIR)
      end

      it "uses the default filename, which incorporates the timestamp" do
        Timecop.freeze do
          expected_filename = described_class::DEFAULT_FILENAME

          expect(subject.filename).to eq(expected_filename)
        end
      end
    end
  end

  describe "#file_with_path" do
    subject { valid_object.file_with_path }

    it { is_expected.to eq(filename_with_path) }
  end

  describe "#to_s" do
    subject { valid_object.to_s }

    it { is_expected.to be_nil }
  end

  describe "#save" do
    subject { valid_object.save }

    it "creates the file when saving" do
      expect do
        subject
      end.to change { File.exist?(filename_with_path) }.from(false).to(true)
    end

    it "writes using :to_s" do
      expect(valid_object).to receive(:to_s)

      subject
    end
  end
end
