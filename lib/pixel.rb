###
# Monkey-patches a transparent? predicate in
###
class Magick::Pixel
  def transparent?
    self.opacity == 65535
  end
end
