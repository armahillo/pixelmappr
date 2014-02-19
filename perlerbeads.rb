#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require './lib/perler.rb'
require './lib/pixel.rb'

p = Perler.new("/home/aaron/Desktop/link.gif")

#p.beads_needed
#puts p.to_s
p.to_html
#puts Perler.render_grid_with_all_colors
