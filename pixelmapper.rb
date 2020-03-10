#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'rmagick'
require './lib/pixelmapper/color.rb'
require './lib/magick/pixel.rb'
require './lib/pixelmapper/perler.rb'
require './lib/pixelmapper/grid.rb'
require './lib/pixelmapper/palette.rb'

include Pixelmapper

ALLOWED_EXTENSIONS = '(jpg|png|gif|jpeg)'

def export_image(image, file = nil)
  file ||= image.gsub(/#{ALLOWED_EXTENSIONS}/, "html")
  Perler.new(image).grid.export(file)
end

if ARGV.count.zero?
  puts "#{__FILE__} <image file|*.files> [output file]"
  exit false
end

input = ARGV.shift
output = ARGV.shift

input = input.chomp("/")
dir = File.dirname(input)
file = File.basename(input)

# Process as a collection
if file.match?(/\*\.#{ALLOWED_EXTENSIONS}/)
  Dir.glob(input) do |file|
    export_image(input)
  end

# Process as a single file
elsif file.match?(/[^\.\*]\.#{ALLOWED_EXTENSIONS}/)
  export_image(input, output)
end