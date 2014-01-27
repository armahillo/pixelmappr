#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require './lib/perler.rb'

p = Perler.new("spec/data/plumber.gif")

p.beads_needed
p.to_grid
