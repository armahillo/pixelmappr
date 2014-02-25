
module Perlerbeads

class Color

  attr_reader :rgba, :xyz, :lab, :name

  ## TODO: convert to 8bit

  def initialize(r,g,b,a = "FFFF", name = nil)
    @red = r.length == 2 ? r : r[0..1]
    @green = g.length == 2 ? g : g[0..1]
    @blue = b.length == 2 ? b : b[0..1]
    @alpha = a.length == 2 ? a : a[0..1]
    @rgba = [@red,@green,@blue,@alpha]
    @xyz = rgb_to_xyz
    @lab = xyz_to_lab
    @name = name
  end
  
  def to_hex
    [@red,@green,@blue,@alpha]
  end
  
  def to_int
    [@red.to_i(16),@green.to_i(16),@blue.to_i(16),@alpha.to_i(16)]
  end
    
  def eq?(other)
    (@rgba == other.rgba)
  end
  
  def to_s
    "##{@red}#{@green}#{@blue}"
  end
  
  def closest_match(*color_list)
    best_match = color_list.pop
    best_score = Color.deltaE94(self, best_match)
    color_list.each do |c|
      score = Color.deltaE94(self, c)
      if (score < best_score)
        best_score = score
        best_match = c
      end
    end
    return best_match
  end
  
  def self.deltaE(color_1, color_2)
    return 0 if color_1.eq?(color_2)
    
    lab1 = color_1.lab
    lab2 = color_2.lab
    k2 = 0.015
    k1 = 0.045
    kl = 1
    kc = 1
    kh = 1
    
    c1 = Math.sqrt(lab1[:a]**2 + lab1[:b]**2)
    c2 = Math.sqrt(lab2[:a]**2 + lab2[:b]**2)
    
    sl = 1
    sc = 1 + k1 * c1
    sh = 1 + k2 * c1
    
    da = lab1[:a] - lab2[:a]
    db = lab1[:b] - lab2[:b]
    dc = c1 - c2
    dl = lab1[:L] - lab2[:L]

    dh = Math.sqrt(da**2 + db**2 - dc**2) || 0.0
    
    l_group = (dl/(kl*sl))**2
    c_group = (dc/(kc*sc))**2
    h_group = (dh/(kh*sh))**2
    Math.sqrt(l_group + c_group + h_group)
  end
  
  ###
  # result of ~2.3 = JND
  ###
  def self.deltaE76(color_1, color_2)
    dL = color_2.lab[:L] - color_1.lab[:L]
    da = color_2.lab[:a] - color_1.lab[:a]
    db = color_2.lab[:b] - color_1.lab[:b]
    Math.sqrt((dL**2)+(da**2)+(db**2))
  end
  
  def self.deltaE94(color_1, color_2)
    k1 = 0.045
    k2 = 0.015
    
    l1 = color_1.lab[:L]
    l2 = color_2.lab[:L]
    a1 = color_1.lab[:a]
    a2 = color_2.lab[:a]
    b1 = color_1.lab[:b]
    b2 = color_2.lab[:b]
    
    dL = l1 - l2
    da = a1 - a2
    db = b1 - b2
    
    c1 = Math.sqrt((a1**2)+(b1**2))
    c2 = Math.sqrt((a2**2)+(b2**2))
    dCab = c1 - c2
    radical = (da**2) + (db**2) - (dCab**2)
    
    dHab = (radical > 0) ? Math.sqrt(radical) : 0

    kL = 1
    kC = 1 #
    kH = 1 #
    
    sL = 1
    sC = 1 + k1*c1
    sH = 1 + k2*c1
    
    composite_L = (dL / (kL*sL))
    composite_C = (dCab / (kC*sC))
    composite_H = (dHab / (kH*sH))
    Math.sqrt((composite_L**2) + (composite_C**2) + (composite_H**2))
  end
  
private
  def pivot_rgb(v)
    if (v > 0.04045)
      (((v + 0.055) / 1.055) ** 2.4) * 100
    else
      (v / 12.92) * 100
    end
  end
  
  def f_t(t)
    t_lower_bound = 0.008856 # (6/29)^3
    alternate_coefficient = 7.787 # (1.0/3)*((29.0/6)**2)
    alternate_intercept = 0.1379 # 4/29
    
    if (t > t_lower_bound)
      return t ** (1.0/3)
    else
      return (alternate_coefficient * t) + alternate_intercept
    end
  end
  def rgb_to_xyz
    r,g,b,a = self.to_int.map do |i| i/255.0; end

    r = pivot_rgb(r)
    g = pivot_rgb(g)
    b = pivot_rgb(b)
    
    {x: (r*0.4124 + g*0.3576 + b*0.1805), 
     y: (r*0.2126 + g*0.7152 + b*0.0722),
     z: (r*0.0193 + g*0.1192 + b*0.9505)}
  end  
  def xyz_to_lab
    ref = [95.047, 100.00, 108.883]
    x = @xyz[:x] / ref[0]
    y = @xyz[:y] / ref[1]
    z = @xyz[:z] / ref[2]
    
    x = f_t(x)
    y = f_t(y)
    z = f_t(z)
   
    {L:((116 * y) - 16),
     a:(500 * (x - y)),
     b:(200 * (y - z))}
  end
end

end
