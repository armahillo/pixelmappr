# frozen_string_literal: true

module Pixelmapper
  # Defines one ImageMagick Image type for PerlerBead palettes
  class Perler < Magick::Image::View
    attr_reader :image, :colors, :beads, :grid, :palette

    def initialize(img_path, palette_yml = './palettes/perler.yml') # rubocop:disable Lint/MissingSuper
      @image = Magick::Image.read(img_path).first
      @palette = Palette.new(palette_yml)
      @grid = Grid.new(columns, rows)
      analyze
    end

    ###
    # Geometry Properties
    ###
    def rows
      @image.rows
    end

    def columns
      @image.columns
    end

    def total_pixels
      rows * columns
    end

    ###
    # Reports
    ###
    def beads_needed
      @beads.each do |color, qty|
        next if color == 'empty'

        puts "#{qty} of #{color}"
      end
    end

    def to_s # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      puts 'PATTERN'
      cols = @image.columns
      @grid.each_index do |i|
        puts '' if (i % cols).zero? && i.positive?
        print @grid[i] == '0' ? '.' : @grid[i]
        print ' '
      end
      puts ''
      puts 'Legend:'
      @colors.each_index do |i|
        puts "#{i.to_s(16)}: #{@colors[i]}"
      end
    end

    def to_html(cols = @image.columns) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      styles = '<style type="text/css">table tr td { width: 15px; height: 15px; }'
      legend = ''
      @colors.each_index do |i|
        styles += ".color_#{i.to_s(16)} { background-color: #{@colors[i]}; }"
        legend += "<tr><td class=\"color_#{i.to_s(16)}\">&nbsp;</td><td>#{@colors[i].name}  #{@colors[i]}</td></tr>"
      end
      styles += '</style>'
      cells = '<tr>'
      @grid.each_index do |i|
        cells += '</tr><tr>' if (i % cols).zero? && i.positive?
        cells += @grid[i] == '0' ? '<td>&nbsp;</td>' : "<td class=\"color_#{@grid[i]}\">#{@grid[i]}</td>"
        print ' '
      end
      File.write("export/dump-#{Time.now.to_f.to_s.gsub('.', '')}.html",
                 "<!doctype html><head>#{styles}</head><body>
                 <table>#{cells}</table> <table>#{legend}</table>
                 </body></html>")
    end

    def self.render_grid_with_all_colors(show_names = false) # rubocop:disable Metrics/MethodLength, Style/OptionalBooleanParameter
      styles = '<style type="text/css">table tr td { width: 35px; height: 35px; }'
      legend = '<tr>'
      row = 1
      @palette.each do |name, color|
        column_limit = show_names ? 4 : 6
        styles += ".#{name} { background-color: #{color}; }"
        legend += "<td class=\"#{name}\"><abbr title=\"#{color}\">&nbsp;</abbr></td>"
        legend += "<td>#{name}</td>" if show_names
        legend += '</tr><tr>' if (row % column_limit).zero?
        row += 1
      end
      legend += '</tr>'
      styles += '</style>'
      puts "<!doctype html><head>#{styles}</head><body><table>#{legend}</table></body></html>"
    end

    ###
    # Perler analysis properties
    ###
    def analyze # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      transparent_color = generate_transparent_color(@image.transparent_color)

      @image.each_pixel do |pixel, _c, _r|
        o = Color.new(pixel.red.to_s(16), pixel.green.to_s(16), pixel.blue.to_s(16), pixel.alpha.to_s(16))
        color = if o == transparent_color || pixel.transparent?
                  @palette.transparent
                else
                  o.closest_match(*@palette.colors.values)
                end
        @grid << color
      end
      @beads = @grid.manifest
    end

    def total_beads
      @beads.values.inject(:+) - (@beads['empty'] || 0)
    end

    # We're expecting these to be in 16-bit
    def generate_transparent_color(original)
      original = original.delete_prefix('#')

      case original.length
      when 6, 8 # RRGGBB, RRGGBBAA
        original.gsub!(/(.{2})/, '\1\1')
      when 12, 16 # RRRRGGGGBBBB
        # NOOP
      else
        raise ArgumentError(original)
      end

      r, g, b, a = original.scan(/.{4}/)

      Color.new(r, g, b, a, 'transparent')
    end
  end
end
