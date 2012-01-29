module AnsiChameleon
  module ArrayUtils

    def self.item_spread_map(array, items)
      remaining_items = items.dup

      map = array.inject('') do |agg, array_item|
        if array_item == remaining_items.first
          agg << '1'
          remaining_items.shift
        else
          agg << '0'
        end
        agg
      end

      remaining_items.any? ? nil : map
    end
  end
end
