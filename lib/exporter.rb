# frozen_string_literal: true

require 'fileutils'

class Exporter
  DEFAULT_DIR = "export"
  DEFAULT_FILENAME = "dump-#{ ->(){ Time.now.to_f.to_s.gsub('.', '')} }"

  attr_reader :dir, :filename

  def initialize(filename_with_path = nil, &block)
    @dir, @filename = sanitize(filename_with_path, &block)
  end

  def to_s
    @data
  end

  def save
    File.write(file_with_path, to_s)
  end

  def file_with_path
    File.join(dir, filename)
  end

  private

  def sanitize(file_with_path = nil, &block)
    dir = File.dirname(file_with_path) rescue DEFAULT_DIR
    filename = File.basename(file_with_path) rescue DEFAULT_FILENAME

    if block_given?
      [yield(dir, filename)].flatten
    else
      [dir, filename]
    end
  end
end