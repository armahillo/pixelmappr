require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

desc "Maps an image" 
task :map, [:input, :output] do |t, args|
  `/usr/bin/env ruby ./pixelmapper.rb #{args[:input]} #{args[:output]}`
end


task default: :spec
