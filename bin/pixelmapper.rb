#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require_relative '../lib/pixelmapper'

ALLOWED_EXTENSIONS = '(jpg|png|gif|jpeg)'

def export_image(image, file)
  output = file.gsub(/#{ALLOWED_EXTENSIONS}/, 'html')
  puts "Processing #{image} into #{output}"
  Pixelmapper::Perler.new(image).grid.export(output)
end

if ARGV.count.zero?
  puts "#{__FILE__} <image file|*.files> [output file]"
  exit false
end

input = ARGV.shift
output = ARGV.shift

input = input.chomp('/')
File.dirname(input)
file = File.basename(input)

# Process as a collection
if file.match?(/\*\.#{ALLOWED_EXTENSIONS}/)
  Dir.glob(input) do |file|
    output ||= "./export/#{File.basename(file)}"
    export_image(file, output)
  end

# Process as a single file
elsif file.match?(/[^.*]\.#{ALLOWED_EXTENSIONS}/)
  output ||= "./export/#{File.basename(input)}"
  export_image(input, output)
end
