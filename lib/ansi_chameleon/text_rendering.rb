module AnsiChameleon
  class TextRendering

    PROPERTY_NAMES = [:effect, :foreground_color, :background_color].freeze

    def initialize(style_sheet_handler)
      @style_sheet_handler = style_sheet_handler
      @stack = Stack.new
      @rendered_text = ''

      original_style = {}

      @stack.push(:style => style_for(nil))
      rendered_text << sequence_for(current_style) unless current_style == original_style
    end

    def push_opening_tag(tag)
      original_style = current_style

      @stack.push(:style => style_for(tag), :tag => tag)
      rendered_text << sequence_for(current_style) unless current_style == original_style
    end

    def push_closing_tag(tag)
      original_style = current_style

      @stack.pop
      rendered_text << sequence_for(current_style) unless current_style == original_style
    end

    def push_text(text)
      rendered_text << text
    end

    def to_s
      rendered_text + (current_style == {} ? '' : sequence_for({}))
    end

    private

    attr_reader :rendered_text

    def current_style
      @stack.top_style
    end

    def sequence_for(style)
      AnsiChameleon::SequenceGenerator.generate(
        style[:effect          ],
        style[:foreground_color],
        style[:background_color]
      )
    end

    def style_for(tag)
      PROPERTY_NAMES.inject({}) do |style, property_name|
        if property_value = @style_sheet_handler.value_for(tag, property_name)
          style[property_name] = case property_value
                                 when :inherit, 'inherit'
                                   current_style[property_name]
                                 else
                                   property_value
                                 end
        end
        style
      end
    end
  end
end
