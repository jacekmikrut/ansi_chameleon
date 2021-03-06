module AnsiChameleon
  class TextRendering

    DEFAULT_STYLE = {
      :effect_name           => :none,
      :foreground_color_name => :white,
      :background_color_name => :black
    }

    def initialize(style_sheet_handler)
      @style_sheet_handler = style_sheet_handler
      @stack = []
      @current_style = DEFAULT_STYLE.merge(@style_sheet_handler.default_values)

      @rendered_text = ''
      @rendered_text << sequence_for(@current_style)
    end

    def push_opening_tag(tag_name)
      @stack.push({ :tag_name => tag_name, :outer_style => @current_style })

      @current_style = deduce_current_style
      @rendered_text << sequence_for(@current_style)
    end

    def push_closing_tag(tag_name)
      unless tag_names_chain.last == tag_name
        raise SyntaxError.new("Encountered </#{tag_name}> tag that had not been opened yet")
      end

      @current_style = @stack.pop[:outer_style]
      @rendered_text << sequence_for(@current_style)
    end

    def push_text(text)
      @rendered_text << text
    end

    def to_s
      if @stack.any?
        tag_names = @stack.map { |data| "<#{data[:tag_name]}>" }.join(', ')
        msg_prefix = @stack.size == 1 ? "Tag #{tag_names} has" : "Tags #{tag_names} have"
        raise SyntaxError.new(msg_prefix + " been opened but not closed yet")
      end

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

    def tag_names_chain
      @stack.map { |data| data[:tag_name] }
    end

    def property_names
      DEFAULT_STYLE.keys
    end

    def deduce_current_style
      property_names.inject({}) do |style, property_name|
        property_value = @style_sheet_handler.value_for(*tag_names_chain, property_name)
        style[property_name] = [:inherit, nil].include?(property_value) ? @current_style[property_name] : property_value
        style
      end
    end

  end
end
