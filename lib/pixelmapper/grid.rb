# frozen_string_literal: true

require 'fileutils'

module Pixelmapper
  # Defines a grid output for rendering the pixelmatched result
  class Grid
    attr_accessor :width, :height, :data

    ##
    # Returns a dataset that includes a list of all color names, hexcodes used in this grid
    # Format: [ { :hexcode => "#FFFFFF", :name => "white"}, { :hexcode => "#000000", :name => "black"} ... ]
    ##
    attr_reader :legend

    ##
    # Returns a dataset that indicates how many of each color is necessary to produce this grid
    # Format: { "name1" => qty1, "name2" => qty2 ...}
    ##
    attr_reader :manifest

    def initialize(width, height)
      @width = width
      @height = height
      @data = []
      @encoded_hexcodes = { 0 => '' }
      @encoded_names = { 0 => 'empty' }
      @manifest = {}
      @legend = []
    end

    ##
    # Appends a new cell to the grid and updates the legend if it's a new color
    ##
    def <<(color = nil) # rubocop:disable Metrics/AbcSize
      @data << color
      return if color.nil?

      unless @encoded_hexcodes.values.include?(color.to_s)
        @encoded_hexcodes[@encoded_hexcodes.length] = color.to_s
        @encoded_names[@encoded_names.length] = color.name
        @legend = @encoded_hexcodes.keys.map { |i| { hexcode: @encoded_hexcodes[i], name: @encoded_names[i] } }
      end
      @manifest[color.name] = @data.count(color)
    end

    def to_a
      result = []
      (@data.length / width).times do |i|
        result << @data[i * width, width]
      end
      result
    end

    # Prints the contents of the grid
    # to STDOUT with space in between the cells
    def to_s
      output = ''
      to_a.each do |r|
        row = r.collect do |c|
          Grid.encode_index(@encoded_hexcodes.key(c.to_s)).to_s
        end
        output += row.join(' ')
        output += "\n"
      end
      output
    end

    # Prints the grid out to HTML format
    # using CSS to color the cells
    def to_html(with_color = true, with_legend = true, with_manifest = false) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Style/OptionalBooleanParameter
      styles = "
<style type=\"text/css\">
table tr td.box { width: 15px; height: 15px; }
table.grid tr td { border: 1px dotted #999; text-align: center; }
table.legend tr td.box { border: 1px solid black; }
table.legend tr td.color_0 { border: 1px dotted black !important; }
"
      styles += '.legend { display: none; }' unless with_legend
      styles += '.manifest { display: none; }' unless with_manifest

      legend_html = "<tr><td class=\"box color_0\">&nbsp;</td><td>&nbsp; empty</td></tr>\n"

      legend.each_with_index do |v, i|
        next if i.zero?

        styles += ".color_#{i} { background-color: #{v[:hexcode]}; }\n"
        legend_html += "<tr><td class=\"box color_#{i}\">&nbsp;</td>"
        legend_html += "<td>#{Grid.encode_index(i)} #{v[:name]} (#{@manifest[v[:name]]})</td></tr>\n"
      end
      styles += "</style>\n"

      rownum = 0
      pattern = ''

      to_a.each do |r|
        pattern += "<tr id=\"row-#{rownum}\">"
        r.each do |c|
          encoded_hexcode = @encoded_hexcodes.key(c.to_s)
          style = with_color ? "color_#{encoded_hexcode}" : ''
          pattern += "<td class=\"box #{style}\">"
          pattern += "#{encoded_hexcode.zero? ? '&nbsp;' : Grid.encode_index(encoded_hexcode)}</td>"
        end
        rownum += 1
        pattern += "\n</tr>\n"
      end

      "<!doctype html><head>#{styles}</head><body>\n<table class=\"grid\">\n#{pattern}\n</table>\n<table class=\"legend\">\n#{legend_html}\n</table>\n</body></html>"
    end

    def self.encode_index(index)
      index.to_i.to_s(36)
    end


  end
end
