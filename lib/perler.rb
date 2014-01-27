require 'RMagick'
include Magick

###
# Monkey-patches a transparent? predicate in
###
class Pixel
  def transparent?
    self.opacity == 65535
  end
end

class Perler < Image::View
  attr_reader :image, :colors, :beads

  def initialize (img_path)
    @image = Image.read(img_path).first
    @colors = ["empty"]
    @beads = {"empty" => 0}
    @grid = []
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
  def to_grid
    puts "PATTERN"
    cols = @image.columns
    @grid.each_index do |i|
      puts "" if (i % cols == 0) and (i > 0)
      symbol = (@grid[i] == "0") ? ". " : @grid[i] + " "
      print symbol
    end
    puts ""
    puts "Legend:"
    @colors.each_index do |i|
      puts i.to_s(16) + ": " + @colors[i]
    end
  end
###
# Perler analysis properties
###
  def analyze
    @image.each_pixel do |pixel,c,r|
      color = pixel.transparent? ? "empty" : pixel.to_color
      @colors << color unless @colors.include?(color)
      @grid << @colors.index(color).to_s(16)
      if (@beads.keys.include?(color))
        @beads[color] += 1
      else 
        @beads[color] = 1
      end
    end
  end

  def total_beads
    @beads.values.inject(:+) - @beads["empty"]
  end
end

