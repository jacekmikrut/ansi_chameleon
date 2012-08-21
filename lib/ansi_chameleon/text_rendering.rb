module AnsiChameleon
  class TextRendering

    DEFAULT_STYLE = {
      :effect_name           => :none,
      :foreground_color_name => :white,
      :background_color_name => :black
    }.freeze

    def initialize(style_sheet_handler)
      @style_sheet_handler = style_sheet_handler
      @stack = Stack.new

      @current_style = DEFAULT_STYLE.dup
      @current_style = deduce_current_style

      @rendered_text = ''
      @rendered_text << sequence_for(@current_style)
    end

    def push_opening_tag(tag)
      @stack.push(:tag => tag, :outer_style => @current_style)

      @current_style = deduce_current_style
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
        style[:effect_name],
        style[:foreground_color_name],
        style[:background_color_name]
      )
    end

    def property_names
      DEFAULT_STYLE.keys
    end

    def deduce_current_style
      property_names.inject({}) do |style, property_name|
        property_value = @style_sheet_handler.value_for(@stack.top_tag, property_name)
        style[property_name] = [:inherit, nil].include?(property_value) ? @current_style[property_name] : property_value
        style
      end
    end

  end
end
