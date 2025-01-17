require 'fileutils'

module Pixelmapper

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
    @encoded_hexcodes = {0 => ""}
    @encoded_names = {0 => "empty"}
    @manifest = {}
    @legend = []
  end

  ## 
  # Appends a new cell to the grid and updates the legend if it's a new color
  ##
  def <<(color = nil)
    @data << color
    return if color.nil?
    unless @encoded_hexcodes.values.include?(color.to_s)
      @encoded_hexcodes[@encoded_hexcodes.length] = color.to_s
      @encoded_names[@encoded_names.length] = color.name 
      @legend = @encoded_hexcodes.keys.map { |i| Hash["hexcode": @encoded_hexcodes[i], "name": @encoded_names[i]] }
    end
    @manifest[color.name] = @data.count(color)
  end

  def to_a
    result = []
    (@data.length / width).times do |i|
      result << @data[i*width,width]
    end
    return result
  end
  
  # Prints the contents of the grid
  # to STDOUT with space in between the cells
  def to_s
    output = ""
    self.to_a.each do |r|
      r.each do |c|
        output += "#{Grid.encode_index(@encoded_hexcodes.key(c.to_s))} "
      end
      output += "\n"
    end
    output
  end
  
  # Prints the grid out to HTML format
  # using CSS to color the cells
  def to_html(with_color = true, with_legend = true, with_manifest = false)
    styles = "
<style type=\"text/css\">
table tr td.box { width: 15px; height: 15px; } 
table.grid tr td { border: 1px dotted #999; text-align: center; } 
table.legend tr td.box { border: 1px solid black; } 
table.legend tr td.color_0 { border: 1px dotted black !important; }
"
    styles += ".legend { display: none; }" unless with_legend
    styles += ".manifest { display: none; }" unless with_manifest

    legend_html = "<tr><td class=\"box color_0\">&nbsp;</td><td>&nbsp; empty</td></tr>\n"

    legend.each_with_index do |v,i|
      next if i == 0
      styles += ".color_#{i} { background-color: #{v[:hexcode]}; }\n"
      legend_html += "<tr><td class=\"box color_#{i}\">&nbsp;</td><td>#{Grid.encode_index(i)} #{v[:name]} (#{@manifest[v[:name]]})</td></tr>\n"
    end
    styles += "</style>\n"
    
    rownum = 0
    pattern = ''

    self.to_a.each do |r|
      pattern += "<tr id=\"row-#{rownum}\">"
      r.each do |c|
        encoded_hexcode = @encoded_hexcodes.key(c.to_s)
        style = with_color ? "color_#{encoded_hexcode}" : ""
        pattern += "<td class=\"box #{style}\">#{encoded_hexcode == 0 ? "&nbsp;" : Grid.encode_index(encoded_hexcode)}</td>"
      end
      rownum += 1
      pattern += "\n</tr>\n"
    end
    return "<!doctype html><head>#{styles}</head><body>
<table class=\"grid\">
#{pattern}
</table>
<table class=\"legend\">
#{legend_html}
</table>
</body></html>"
  end
  
  def export(file = nil, with_color = true, with_legend = true, with_manifest = false)
    file_with_path = sanitize_destination_file(file)
    File.open("#{file_with_path}",'w') { |f| f.write(self.to_html(with_color, with_legend, with_manifest)) }
  end

  def Grid.encode_index(v)
    v.to_i.to_s(36)
  end

private
  def sanitize_destination_file(file_with_path = nil)
    file_with_path ||= Grid.default_filename
    dir = File.dirname(file_with_path)
    dir = Dir.exists?(dir) ? dir : "export"
    filename = File.basename(file_with_path)
    if filename[-4,4] != "html" then filename += ".html" end
    dir + "/" + filename
  end

  def Grid.default_filename
    "export/dump-#{Time.now.to_f.to_s.gsub(/\./,'')}.html"
  end

=begin  
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
  
    
  end
=end  
end

end
