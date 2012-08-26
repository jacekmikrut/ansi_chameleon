module AnsiChameleon
  class TextRendering
    module SyntaxValidator

      def push_closing_tag(tag)
        unless @stack.top_tag_name == tag.name
          raise SyntaxError.new("Encountered #{tag.original_string} tag that had not been opened yet")
        end

        super
      end

      def to_s
        if @stack.top_tag
          tag_original_strings = @stack.tags.map { |tag| tag.original_string }.join(', ')
          msg_prefix = @stack.tags.size == 1 ? "Tag #{tag_original_strings} has" : "Tags #{tag_original_strings} have"
          raise SyntaxError.new(msg_prefix + " been opened but not closed yet")
        end

        super
      end
    end
  end
end
