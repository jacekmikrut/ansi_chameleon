module AnsiChameleon
  class TextRenderer

    CHUNK_REGEX = /<\/?[_a-zA-Z]\w*>|[\w\.]+|\S|\s/.freeze
    OPENING_TAG_REGEX = /\A<[^\/].*>\z/.freeze
    CLOSING_TAG_REGEX = /\A<\/.+>\z/.freeze

    def initialize(style_sheet)
      @style_sheet_handler = StyleSheetHandler.new(style_sheet, StylePropertyNameTranslator)
    end

    def render(text)
      text_rendering = TextRendering.new(@style_sheet_handler)

      chunks(text).each do |chunk|
        case
        when opening_tag?(chunk)
          text_rendering.push_opening_tag(tag_name(chunk))

        when closing_tag?(chunk)
          text_rendering.push_closing_tag(tag_name(chunk))

        else
          text_rendering.push_text(chunk)

        end
      end

      text_rendering.to_s
    end

    private

    def chunks(text)
      text.scan(CHUNK_REGEX)
    end

    def opening_tag?(chunk)
      chunk =~ OPENING_TAG_REGEX
    end

    def closing_tag?(chunk)
      chunk =~ CLOSING_TAG_REGEX
    end

    def tag_name(chunk)
      chunk.match(/^<\/?(?<tag_name>.*)>$/)[:tag_name]
    end
  end
end
