# frozen_string_literal: true

module Magick
  # Monkey-patches a transparent? predicate into Magick::Pixel
  class Pixel
    def transparent?
      alpha.zero?
    end
  end
end
