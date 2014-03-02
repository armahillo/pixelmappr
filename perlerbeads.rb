#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'RMagick'
require './lib/perlerbeads/color.rb'
require './lib/magick/pixel.rb'
require './lib/perlerbeads/perler.rb'
require './lib/perlerbeads/grid.rb'

include Perlerbeads

p = Perler.new("/home/aaron/Desktop/witchhouse.jpg")

#p.beads_needed
puts p.total_beads
#p.grid.export
#puts Perler.render_grid_with_all_colors
