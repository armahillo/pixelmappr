###
# Monkey-patches a transparent? predicate in
###

module Magick
  class Pixel
    def transparent?
      self.alpha == 0
    end
  end
end