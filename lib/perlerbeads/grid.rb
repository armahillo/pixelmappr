
module Perlerbeads

class Grid

  attr_accessor :width, :height, :data
  
  def initialize(width, height)
    @width = width
    @height = height
    @data = []
  end

  def <<(color)
    @data << color
  end

  def legend
    colors = {0 => ""}
    @data.flatten.uniq.each { |c| colors[colors.length] = c.to_s }
    return colors
  end
  

  def manifest
    colors = @data.flatten.uniq
    manifest = {}
    colors.each do |c|
      manifest[c.to_s] = @data.count(c)
    end
    return manifest
  end
  
  def to_a
    result = []
    (@data.length / width).times do |i|
      result << @data[i*width,width]
    end
    return result
  end
  
  def to_s
    l = self.legend
    output = ""
    self.to_a.each do |r|
      r.each do |c|
        output += "#{l.key(c.to_s).to_i.to_s(36)} "
      end
      output += "\n"
    end
    output
  end
  
  def to_html
    styles = "<style type=\"text/css\">table tr td { width: 15px; height: 15px; } table.grid tr td { border: 1px dotted #999; text-align: center; } table.legend tr td.box { border: 1px solid black; } table.legend tr td.color_0 { border: 1px dotted black !important; }"
    legend = self.legend
    legend_html = ""
    pattern = "<tr>"
    legend.each do |key,hexcode|
      styles += ".color_#{key} { background-color: #{hexcode}; }"
      legend_html += "<tr><td class=\"box color_#{key}\">&nbsp;</td><td>#{(key == 0 ? "&nbsp;" : key)}</td></tr>"
    end
    styles += "</style>"
    
    
    self.to_a.each do |r|
      r.each do |c|
        pattern += "<td class=\"color_#{c.to_s}\">#{(c.to_s == 0 ? "&nbsp;" : legend.key(c.to_s))}</td>"
      end
      pattern += "</tr><tr>"
    end
    return "<!doctype html><head>#{styles}</head><body>
      <table class=\"grid\">#{pattern}</table>
      <table class=\"legend\">#{legend_html}</table>
      </body></html>"
  end
  
  def export
    File.open("export/dump-#{Time.now.to_f.to_s.gsub(/\./,'')}.html",'w') { |f| f.write(self.to_html) }
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
