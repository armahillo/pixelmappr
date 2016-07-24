#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'RMagick'
require './lib/pixelmapper/color.rb'
require './lib/magick/pixel.rb'
require './lib/pixelmapper/perler.rb'
require './lib/pixelmapper/grid.rb'

include Pixelmapper

image = ARGV.shift
p = Perler.new(image)

output = (ARGV.count > 0) ? ARGV.shift : nil

if output
    File.open(output, 'w+') do |file|
		file.puts p.grid.to_html
	end
else
	puts p.grid.to_html
	
end
  
#puts p.beads_needed
#puts p.total_beads
#p.grid.export
#puts Perler.render_grid_with_all_colors(true)
#puts p.grid.to_html
