## frozen_string_literal: true
#
#require 'exporter'
#
#
#xdescribe Html do
#  before do
#    # Reset the export location
#    ::FileUtils.rm_rf('./spec/export')
#    ::FileUtils.mkdir('./spec/export')
#  end
#
#  let(:good_path) { './spec/export/' }
#  let(:good_filename) { 'output.html' }
#  let(:filename_with_path) { File.join(good_path, good_filename) }
#
#  subject(:valid_object) { described_class.new(filename_with_path) }
#
#  describe ".new" do
#    let(:non_html_filename) { 'output.txt' }
#    subject { described_class.new(non_html_filename) }
#
#    it 'appends html if that is not provided' do
#      expect(subject.filename).to be_end_with('html')
#    end
#  end
#
#  describe "#data" do
#    subject { valid_object.data }
#
#    it { is_expected.to be_match(/html.*head.*\/head.*body.*\/body.*\/html/) }
#  end
#end
