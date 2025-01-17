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
      "<!doctype html><head>#{styles}</head><body>
<table class=\"grid\">
#{pattern}
</table>
<table class=\"legend\">
#{legend_html}
</table>
</body></html>"
    end

    def export(file = nil, with_color = true, with_legend = true, with_manifest = false) # rubocop:disable Metrics/ParameterLists, Style/OptionalBooleanParameter
      file_with_path = sanitize_destination_file(file)
      File.write(file_with_path.to_s, to_html(with_color, with_legend, with_manifest))
    end

    def self.encode_index(index)
      index.to_i.to_s(36)
    end

    def self.default_filename
      "export/dump-#{Time.now.to_f.to_s.gsub('.', '')}.html"
    end

    private

    def sanitize_destination_file(file_with_path = nil)
      file_with_path ||= Grid.default_filename
      dir = File.dirname(file_with_path)
      dir = 'export' unless Dir.exist?(dir)
      filename = File.basename(file_with_path)
      filename += '.html' if filename[-4, 4] != 'html'
      "#{dir}/#{filename}"
    end

    #   def self.render_grid_with_all_colors
    #     styles = "<style type=\"text/css\">table tr td { width: 15px; height: 15px; }"
    #     legend = "<tr>"
    #     row = 1
    #     @@PERLER_COLORS.each do |name,color|
    #       styles += ".#{name.to_s} { background-color: #{color.to_s}; }"
    #       legend += "<td class=\"#{name.to_s}\"><abbr title=\"#{color.to_s}\">&nbsp;</abbr></td>"
    #       if (row % 6 == 0)
    #         legend += "</tr><tr>"
    #       end
    #       row += 1
    #     end
    #     legend += "</tr>"
    #     styles += "</style>"
    #     puts "<!doctype html><head>#{styles}</head><body><table>#{legend}</table></body></html>"
    #   end
    #
    #   def beads_needed
    #     @beads.each do |color,qty|
    #       next if color == "empty"
    #       puts "#{qty} of #{color}"
    #     end
    #   end
    #   def to_s
    #     puts "PATTERN"
    #     cols = @image.columns
    #     @grid.each_index do |i|
    #       puts "" if (i % cols == 0) and (i > 0)
    #       print (@grid[i] == "0") ? "." : @grid[i]
    #       print " "
    #     end
    #     puts ""
    #     puts "Legend:"
    #     @colors.each_index do |i|
    #       puts i.to_s(16) + ": " + @colors[i].to_s
    #     end
    #   end
    #
    #
    #   end
  end
end
