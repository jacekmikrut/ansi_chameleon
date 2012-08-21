module AnsiChameleon
  class TextRendering
    class Stack

      def initialize
        @items = []
      end

      attr_reader :items

      def push(item)
        item[:tag].parent = top_tag
        items.push(item)
      end

      def pop
        items.pop
      end

      def top_tag
        items.last && items.last[:tag]
      end

      def top_tag_name
        top_tag && top_tag.name
      end
    end
  end
end
