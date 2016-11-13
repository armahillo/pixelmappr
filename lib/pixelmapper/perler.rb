module Pixelmapper

class Perler < Magick::Image::View
  attr_reader :image, :colors, :beads, :grid, :palette

  def initialize (img_path, palette_yml = './palettes/perler.yml')
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
    self.rows * self.columns
  end

###
# Reports
###
  def beads_needed
    @beads.each do |color,qty|
      next if color == "empty"
      puts "#{qty} of #{color}"
    end
  end
  def to_s
    puts "PATTERN"
    cols = @image.columns
    @grid.each_index do |i|
      puts "" if (i % cols == 0) and (i > 0)
      print (@grid[i] == "0") ? "." : @grid[i]
      print " "
    end
    puts ""
    puts "Legend:"
    @colors.each_index do |i|
      puts i.to_s(16) + ": " + @colors[i].to_s
    end
  end
  def to_html(cols = @image.columns)
    styles = "<style type=\"text/css\">table tr td { width: 15px; height: 15px; }"
    legend = ""
    @colors.each_index do |i|
      styles += ".color_#{i.to_s(16)} { background-color: #{@colors[i].to_s}; }"
      legend += "<tr><td class=\"color_#{i.to_s(16)}\">&nbsp;</td><td>#{@colors[i].name}  #{@colors[i].to_s}</td></tr>"
    end
    styles += "</style>"
    cells = "<tr>"
    @grid.each_index do |i|
      cells += "</tr><tr>" if (i % cols == 0) and (i > 0)
      cells += (@grid[i] == "0") ? "<td>&nbsp;</td>" : "<td class=\"color_#{@grid[i]}\">#{@grid[i]}</td>"
      print " "
    end
    File.open("export/dump-#{Time.now.to_f.to_s.gsub(/\./,'')}.html",'w') { |f| f.write("<!doctype html><head>#{styles}</head><body><table>#{cells}</table> <table>#{legend}</table></body></html>") }
  end
  
  def self.render_grid_with_all_colors(show_names = false)
    styles = "<style type=\"text/css\">table tr td { width: 35px; height: 35px; }"
    legend = "<tr>"
    row = 1
    @@PERLER_COLORS.each do |name,color|
      column_limit = show_names ? 4 : 6
      styles += ".#{name.to_s} { background-color: #{color.to_s}; }"
      legend += "<td class=\"#{name.to_s}\"><abbr title=\"#{color.to_s}\">&nbsp;</abbr></td>"
      if (show_names)
        legend += "<td>#{name}</td>"
      end
      if (row % column_limit == 0)
        legend += "</tr><tr>"
      end
      row += 1
    end
    legend += "</tr>"
    styles += "</style>"
    puts "<!doctype html><head>#{styles}</head><body><table>#{legend}</table></body></html>"
  end
###
# Perler analysis properties
###
  def analyze
    @image.each_pixel do |pixel,c,r|
      o = Color.new(pixel.red.to_s(16), pixel.green.to_s(16), pixel.blue.to_s(16))
      color = (pixel.transparent?) ? @palette.transparent : o.closest_match(*@palette.colors.values)
      @grid << color
    end
    @beads = @grid.manifest
  end

  def total_beads
    @beads.values.inject(:+) - (@beads["empty"] || 0)
  end
end

end
