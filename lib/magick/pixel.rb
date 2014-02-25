###
# Monkey-patches a transparent? predicate in
###
module Magick

class Pixel
  def transparent?
    self.opacity == 65535
  end
end

end
