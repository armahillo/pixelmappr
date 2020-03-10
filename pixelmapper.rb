#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'RMagick'
require './lib/pixelmapper/color.rb'
require './lib/magick/pixel.rb'
require './lib/pixelmapper/perler.rb'
require './lib/pixelmapper/grid.rb'
require './lib/pixelmapper/palette.rb'

include Pixelmapper

ALLOWED_EXTENSIONS = '(jpg|png|gif|jpeg)'

if ARGV.count.zero?
  puts "#{__FILE__} <image file|*.files> [output file]"
  exit false
end

input = ARGV.shift
output = ARGV.shift

# Process as a collection
if input.match?(/\*\.#{ALLOWED_EXTENSIONS}/)
  dir,file = input.chomp("/")

# Process as a single file
elsif input.match?(/[^.]\.#{ALLOWED_EXTENSIONS}/)
  output ||= input.gsub(/#{ALLOWED_EXTENSIONS}/, "html")
  Perler.new(image).grid.export(output)
end

#

Dir[dir].each do |file|
  output = file.gsub(/#{ALLOWED_EXTENSIONS}/, "html")
  Perler.new(file).grid.export(output)
end
#p.grid.export(output, true, true, true)
  
#puts p.beads_needed
#puts p.total_beads
#p.grid.export
#puts Perler.render_grid_with_all_colors(true)
#puts p.grid.to_html
