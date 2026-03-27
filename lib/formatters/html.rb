# frozen_string_literal: true

module Formatters
  # Formats content for HTML output
  class Html
    attr_accessor :styles, :body

    def initialize
      @head = ""
      @styles = ""
      @body = ""
    end

    def to_s
      "<!doctype html>
        <head>
          <style type=\"text/css\" rel=\"stylesheet\">
            #{styles}
          </style>

          #{head}
        </head>
        <body>#{body}</body>
      </html>"
    end
  end
end