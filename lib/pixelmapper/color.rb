# frozen_string_literal: true

module Pixelmapper
  # Normalized Color object to use for comparing RGBA values and doing color matching
  class Color # rubocop:disable Metrics/ClassLength
    OPAQUE = 'FFFF'
    TRANSPARENT = '0000'

    attr_reader :rgba, :xyz, :lab, :name

    # Alpha 0000 = Opaque
    # Alpha FFFF = Transparent
    def initialize(red, green, blue, alpha = OPAQUE, name = nil)
      @red = convert_to_8bit(red)
      @green = convert_to_8bit(green)
      @blue = convert_to_8bit(blue)
      @alpha = convert_to_8bit(alpha)

      @rgba = [@red, @green, @blue, @alpha]
      @xyz = rgb_to_xyz
      @lab = xyz_to_lab
      @name = name
    end

    def to_hex
      [@red, @green, @blue, @alpha]
    end

    def to_rgba
      [@red.to_i(16), @green.to_i(16), @blue.to_i(16), @alpha.to_i(16)]
    end
    alias to_int to_rgba

    def to_rgb
      [@red.to_i(16), @green.to_i(16), @blue.to_i(16)]
    end

    def to_xyz
      @xyz.values.map { |v| v.round(2) }
    end

    def to_lab
      @lab.values.map { |v| v.round(2) }
    end

    def ==(other)
      (@rgba == other.rgba)
    end
    alias eq? :==

    def to_s
      "##{@red}#{@green}#{@blue}"
    end

    def closest_match(*color_list)
      best_match = color_list.pop
      best_score = Color.deltaE94(self, best_match)
      color_list.each do |c|
        score = Color.deltaE94(self, c)
        if score < best_score
          best_score = score
          best_match = c
        end
      end
      best_match
    end

    def self.delta_e(color1, color2) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return 0 if color1.eq?(color2)

      lab1 = color1.lab
      lab2 = color2.lab
      k2 = 0.015
      k1 = 0.045
      kl = 1
      kc = 1
      kh = 1

      c1 = Math.sqrt((lab1[:a]**2) + (lab1[:b]**2))
      c2 = Math.sqrt((lab2[:a]**2) + (lab2[:b]**2))

      sl = 1
      sc = 1 + (k1 * c1)
      sh = 1 + (k2 * c1)

      da = lab1[:a] - lab2[:a]
      db = lab1[:b] - lab2[:b]
      dc = c1 - c2
      dl = lab1[:L] - lab2[:L]

      dh = Math.sqrt((da**2) + (db**2) - (dc**2)) || 0.0

      l_group = (dl / (kl * sl))**2
      c_group = (dc / (kc * sc))**2
      h_group = (dh / (kh * sh))**2
      Math.sqrt(l_group + c_group + h_group)
      # Math.sqrt((delta_l ** 2) + (delta_a ** 2) + (delta_b ** 2))
    end

    ###
    # result of ~2.3 = JND
    ###
    def self.deltaE76(color1, color2) # rubocop:disable Naming/MethodName, Metrics/AbcSize
      # rubocop:disable Naming/VariableName
      dL = color2.lab[:L] - color1.lab[:L]
      da = color2.lab[:a] - color1.lab[:a]
      db = color2.lab[:b] - color1.lab[:b]
      Math.sqrt((dL**2) + (da**2) + (db**2))
      # rubocop:enable Naming/VariableName
    end

    def self.deltaE94(color1, color2) # rubocop:disable Naming/MethodName, Metrics/MethodLength, Metrics/AbcSize
      # rubocop:disable Naming/VariableName
      k1 = 0.045
      k2 = 0.015

      l1 = color1.lab[:L]
      l2 = color2.lab[:L]
      a1 = color1.lab[:a]
      a2 = color2.lab[:a]
      b1 = color1.lab[:b]
      b2 = color2.lab[:b]

      dL = l1 - l2
      da = a1 - a2
      db = b1 - b2

      c1 = Math.sqrt((a1**2) + (b1**2))
      c2 = Math.sqrt((a2**2) + (b2**2))
      dCab = c1 - c2
      radical = (da**2) + (db**2) - (dCab**2)

      dHab = radical.positive? ? Math.sqrt(radical) : 0

      kL = 1
      kC = 1
      kH = 1

      sL = 1
      sC = 1 + (k1 * c1)
      sH = 1 + (k2 * c1)

      composite_L = (dL / (kL * sL))
      composite_C = (dCab / (kC * sC))
      composite_H = (dHab / (kH * sH))
      Math.sqrt((composite_L**2) + (composite_C**2) + (composite_H**2))
      # rubocop:enable Naming/VariableName
    end

    private

    def convert_to_8bit(color_value)
      return color_value if color_value.length == 2

      (color_value.hex / 257).to_s(16).rjust(2, '0').upcase
    end

    def convert_to_16bit(color_value)
      return color_value if color_value.length == 4

      (color_value.hex * 257).to_s(16).rjust(4, '0').upcase
    end

    def pivot_rgb(v) # rubocop:disable Naming/MethodParameterName
      if v > 0.04045
        (((v + 0.055) / 1.055)**2.4) * 100
      else
        (v / 12.92) * 100
      end
    end

    def f_t(t) # rubocop:disable Naming/MethodParameterName
      t_lower_bound = 0.008856 # (6/29)^3
      alternate_coefficient = 7.787 # (1.0/3)*((29.0/6)**2)
      alternate_intercept = 0.1379 # 4/29

      if t > t_lower_bound
        t**(1.0 / 3)
      else
        (alternate_coefficient * t) + alternate_intercept
      end
    end

    def rgb_to_xyz # rubocop:disable Metrics/AbcSize
      r, g, b, = to_int.map { |i| i / 255.0 }

      r = pivot_rgb(r)
      g = pivot_rgb(g)
      b = pivot_rgb(b)

      { x: ((r * 0.4124) + (g * 0.3576) + (b * 0.1805)),
        y: ((r * 0.2126) + (g * 0.7152) + (b * 0.0722)),
        z: ((r * 0.0193) + (g * 0.1192) + (b * 0.9505)) }
    end

    def xyz_to_lab # rubocop:disable Metrics/AbcSize
      ref = [95.047, 100.00, 108.883]
      x = @xyz[:x] / ref[0]
      y = @xyz[:y] / ref[1]
      z = @xyz[:z] / ref[2]

      x = f_t(x)
      y = f_t(y)
      z = f_t(z)

      { L: ((116 * y) - 16),
        a: (500 * (x - y)),
        b: (200 * (y - z)) }
    end
  end
end
