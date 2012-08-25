module AnsiChameleon
  class TextRendering

    PROPERTY_NAMES = [:effect, :foreground_color, :background_color].freeze

    DEFAULT_STYLE = {
      :effect           => :none,
      :foreground_color => :white,
      :background_color => :black
    }.freeze

    def initialize(style_sheet_handler)
      @style_sheet_handler = style_sheet_handler
      @stack = Stack.new

      @current_style = DEFAULT_STYLE.dup
      @current_style = style_for(nil)

      @rendered_text = ''
      @rendered_text << sequence_for(@current_style)
    end

    def push_opening_tag(tag)
      @stack.push(:tag => tag, :outer_style => @current_style)

      @current_style = style_for(tag)
      @rendered_text << sequence_for(@current_style)
    end

    def push_closing_tag(tag)
      @current_style = @stack.pop[:outer_style]
      @rendered_text << sequence_for(@current_style)
    end

    def push_text(text)
      @rendered_text << text
    end

    def to_s
      @rendered_text + AnsiChameleon::SequenceGenerator.generate(:reset)
    end

    private

    def sequence_for(style)
      AnsiChameleon::SequenceGenerator.generate(
        style[:effect],
        style[:foreground_color],
        style[:background_color]
      )
    end

    def style_for(tag)
      PROPERTY_NAMES.inject({}) do |style, property_name|
        property_value = @style_sheet_handler.value_for(tag, property_name)
        style[property_name] = case property_value
                               when :inherit, 'inherit'
                                 @current_style[property_name]
                               when nil
                                 DEFAULT_STYLE[property_name]
                               else
                                 property_value
                               end
        style
      end
    end
  end
end
