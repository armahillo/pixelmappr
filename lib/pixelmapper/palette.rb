# frozen_string_literal: true

require 'yaml'

module Pixelmapper
  # Object handler for palettes
  class Palette
    include Enumerable

    attr_reader :colors, :transparent

    def initialize(yml_config = nil)
      @colors = {}
      @transparent = nil
      @name = []
      load(yml_config) unless yml_config.nil?
    end

    def load(palette_yml)
      raise ArgumentError unless File.exist?(palette_yml)

      palette = YAML.load_file(palette_yml)
      @name << (palette['name'] || File.basename(palette_yml).sub('.yml', '').capitalize)
      palette['colors'].each do |name, values|
        @colors[name] = Color.new(values[0], values[1], values[2], values[3] || 'FF', name)
      end

      self
    end

    def name
      @name.join(', ')
    end

    def each(&block)
      colors.values.each(&block)
    end

    def respond_to_missing?(_method_name, _include_private = false)
      @colors.key?(color_name.to_s)
    end

    def method_missing(color_name)
      @colors[color_name.to_s]
    end
  end
end
