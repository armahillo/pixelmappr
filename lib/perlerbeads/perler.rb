module Perlerbeads

class Perler < Magick::Image::View
  attr_reader :image, :colors, :beads, :grid

  #@@TRANSPARENT = Color.new("FF","FF","FF","00", "transparent")
  @@TRANSPARENT = nil

  @@PERLER_COLORS = {
    :black => Color.new("01","01","01","FF", "black"),
    :white => Color.new("FF","FF","FF","FF", "white"),
    :light_pink => Color.new("F5","C8","E6","FF", "light pink"),
    :bubblegum => Color.new("F0","82","AF","FF", "bubblegum"),
    :pink => Color.new("F0","5F","A5","FF", "pink"),
    :magenta => Color.new("FF","3C","82","FF", "magenta"),
    :raspberry => Color.new("BE","46","73","FF", "raspberry"),
    :cranapple => Color.new("BE","46","73","FF", "cranapple"),
    :hot_coral => Color.new("FF","5A","73","FF", "hot coral"),
    :red => Color.new("CD","46","5A","FF", "red"),
    :rust => Color.new("B9","5A","5A","FF", "rust"),
    :peach => Color.new("FA","CD","C3","FF", "peach"),
    :blush => Color.new("FF","96","A0","FF", "blush"),
    :butterscotch => Color.new("F0","96","6E","FF", "butterscotch"),
    :orange => Color.new("FF","73","50","FF", "orange"),
    :creme => Color.new("F0","E6","C3","FF", "creme"),
    :sand => Color.new("DC","C8","AF","FF", "sand"),
    :pastel_yellow => Color.new("F5","F0","73","FF", "pastel yellow"),
    :yellow => Color.new("FF","EB","37","FF", "yellow"),
    :cheddar => Color.new("FA","C8","55","FF", "cheddar"),
    :prickly_pear => Color.new("AF","C8","55","FF", "prickly pear"),
    :kiwi_lime => Color.new("7D","D2","50","FF", "kiwi lime"),
    :pastel_green => Color.new("87","D2","91","FF", "pastel green"),
    :light_green => Color.new("4B","C3","B4","FF", "light green"),
    :green => Color.new("73","B9","73","FF", "green"),
    :dark_green => Color.new("28","8C","64","FF", "dark green"),
    :parrot_green => Color.new("00","96","A5","FF", "parrot green"),
    :toothpaste => Color.new("A0","D7","E1","FF", "toothpaste"),
    :pastel_blue => Color.new("5A","A0","CD","FF", "pastel blue"),
    :turquoise => Color.new("05","96","CD","FF", "turquoise"),
    :light_blue => Color.new("2D","82","C8","FF", "lightblue"),
    :dark_blue => Color.new("23","50","91","FF", "dark blue"),
    :periwinkle_blue => Color.new("55","7D","B9","FF", "periwinkle blue"),
    :pastel_lavender => Color.new("9B","87","CD","FF", "pastel lavender"),
    :plum => Color.new("AF","5A","A0","FF", "plum"),
    :purple => Color.new("78","5F","9B","FF", "purple"),
    :tan => Color.new("CD","A5","87","FF", "tan"),
    :light_brown => Color.new("A0","82","5F","FF", "light brown"),
    :brown => Color.new("6E","5A","55","FF", "brown"),
    :grey => Color.new("96","9B","A0","FF", "grey"),
    :dark_grey => Color.new("5F","64","64","FF", "dark grey")
  }

  def initialize (img_path)
    @image = Magick::Image.read(img_path).first
    #@colors = ["empty"]
    #@beads = {"empty" => 0}
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
      legend += "<tr><td class=\"color_#{i.to_s(16)}\">&nbsp;</td><td>#{@colors[i].to_s}</td></tr>"
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
  
  def self.render_grid_with_all_colors
    styles = "<style type=\"text/css\">table tr td { width: 15px; height: 15px; }"
    legend = "<tr>"
    row = 1
    @@PERLER_COLORS.each do |name,color|
      styles += ".#{name.to_s} { background-color: #{color.to_s}; }"
      legend += "<td class=\"#{name.to_s}\"><abbr title=\"#{color.to_s}\">&nbsp;</abbr></td>"
      if (row % 6 == 0)
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
      color = (pixel.transparent?) ? @@TRANSPARENT : o.closest_match(*@@PERLER_COLORS.values)
      @grid << color
    end
    @beads = @grid.manifest
  end

  def total_beads
    @beads.values.inject(:+) - (@beads["empty"] || 0)
  end
end

end
