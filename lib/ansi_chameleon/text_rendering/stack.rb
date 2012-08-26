module AnsiChameleon
  class TextRendering
    class Stack

      def initialize
        @items = []
      end

      attr_reader :items

      def push(item)
        item[:tag].parent = top_tag if item[:tag]
        items.push(item)
      end

      def pop
        items.pop
      end

      def tags
        items.map { |item| item[:tag] }.compact
      end

      def top_tag
        tags.last
      end

      def top_tag_name
        top_tag && top_tag.name
      end

    end
  end
end
