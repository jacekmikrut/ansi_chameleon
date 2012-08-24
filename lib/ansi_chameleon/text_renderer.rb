module AnsiChameleon
  class TextRenderer

    CHUNK_REGEX = /<\/?#{Tag::NAME_REG}[^>]*>|(?:[^<]|<(?!\/)(?!#{Tag::NAME_FIRST_CHAR_REG})|<\/(?!#{Tag::NAME_FIRST_CHAR_REG})|<[^>]*\z)+/.freeze

    def self.chunks(text)
      text.scan(CHUNK_REGEX)
    end

    def initialize(style_sheet)
      @style_sheet_handler = new_style_sheet_handler(style_sheet)
    end

    def render(text)
      text_rendering = new_text_rendering

      self.class.chunks(text).each do |chunk|
        if tag = Tag.parse(chunk)
          text_rendering.send(
            tag.opening? ? :push_opening_tag : :push_closing_tag,
            tag
          )
        else
          text_rendering.push_text(chunk)
        end
      end

      text_rendering.to_s
    end

    private

    def new_style_sheet_handler(style_sheet)
      SimpleStyleSheet::Handler.new(style_sheet, StylePropertyNameTranslator)
    end

    def new_text_rendering
      TextRendering.new(@style_sheet_handler).extend(TextRendering::SyntaxValidator)
    end
  end
end
