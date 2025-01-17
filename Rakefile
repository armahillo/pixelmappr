# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

desc 'Verifies that the color matching still works as expected'
task :verify do
  `./bin/pixelmapper.rb spec/data/plumber.gif export/plumber.html`

  known_html = File.read('spec/data/plumber.html')
  generated_html = File.read('export/plumber.html')

  if known_html == generated_html
    puts 'OK'
    FileUtils.rm('export/plumber.html')
  else
    puts 'ERROR'
    puts './export/plumber.html'
  end
end

task default: :spec
