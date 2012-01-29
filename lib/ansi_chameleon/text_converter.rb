module AnsiChameleon
  class TextConverter

    def initialize(style_sheet)
      @style_sheet_handler = StyleSheetHandler.new(style_sheet, StylePropertyNameTranslator)
    end

    def convert(text)
      text_conversion = TextConversion.new(@style_sheet_handler)

      chunks(text).each do |chunk|
        case
        when opening_tag?(chunk)
          text_conversion.push_opening_tag(tag_name(chunk))

        when closing_tag?(chunk)
          text_conversion.push_closing_tag(tag_name(chunk))

        else
          text_conversion.push_text(chunk)

        end
      end

      text_conversion.to_s
    end

    private

    def tag_names_regex
      @tag_names_regex ||= @style_sheet_handler.tag_names.map { |tag_name| "(?<=<#{tag_name}>)|(?<=<\/#{tag_name}>)|(?=<\/?#{tag_name}>)" }.join('|')
    end

    def chunk_regex
      @chunk_regex ||= /(?<= |\t)|(?= |\t)#{'|' + tag_names_regex unless tag_names_regex.empty?}/
    end

    def opening_tag_regex
      @opening_tag_regex ||= /^<(?<=[^\/])(?:#{@style_sheet_handler.tag_names.join('|')})>$/
    end

    def closing_tag_regex
      @closing_tag_regex ||= /^<\/#{@style_sheet_handler.tag_names.join('|')}>$/
    end

    def chunks(text)
      text.split(chunk_regex)
    end

    def opening_tag?(chunk)
      chunk =~ opening_tag_regex
    end

    def closing_tag?(chunk)
      chunk =~ closing_tag_regex
    end

    def tag_name(chunk)
      chunk.match(/^<\/?(?<tag_name>.*)>$/)[:tag_name].to_sym
    end
  end
end
