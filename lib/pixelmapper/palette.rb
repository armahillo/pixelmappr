require 'yaml'

module Pixelmapper

  class Palette
  	include Enumerable

  	attr_reader :colors, :transparent

  	def initialize(yml_config = nil)
  		@colors = {}
  		@transparent = nil
  		@name = []
  		load(yml_config) unless yml_config.nil?
  	end

  	def load palette_yml
      raise ArgumentError unless File.exists?(palette_yml)
      palette = YAML.load_file(palette_yml)
      @name << (palette["name"] || File.basename(palette_yml).sub('.yml','').capitalize)
      palette["colors"].each do |name, values|
      	@colors[name] = Color.new(values[0], values[1], values[2], values[3] || "FF", name)
      end
    end

    def name
      @name.join(", ")
    end

  	def each &block
  		self.colors.values.each(&block) 
  	end

  	def method_missing color_name
  		if @colors.has_key?(color_name.to_s)
  			return @colors[color_name.to_s]
  		else
  			begin
  			  super color_name
  			rescue NoMethodError
  			  return nil
  			end
  		end
  	end
  end
end