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

    def self.includes_other_array_items_in_order?(array, other_array)
      return true if other_array.none?

      remaining_array = array.dup
      other_array.each_with_index do |other_array_item|
        if array_item_index = remaining_array.index(other_array_item)
          remaining_array.slice!(0, array_item_index)
        else
          return false
        end
      end
      true
    end
  end
end
