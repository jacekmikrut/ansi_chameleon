module AnsiChameleon
  class StyleSheetHandler

    def initialize(style_sheet_hash, property_name_translator=nil)
      @map = {}
      @default_values = {}
      @property_name_translator = property_name_translator
      populate_map(style_sheet_hash)
    end

    attr_reader :map, :default_values, :property_name_translator

    def tag_names
      map.keys
    end

    def value_for(*tag_names_chain, property_name)
      strongest = strongest_style_definition(*(tag_names_chain.map { |tag_name| tag_name.to_sym }), property_name.to_sym)
      strongest ? strongest[:value] : default_values[property_name.to_sym]
    end

    private

    def populate_map(style_definition_hash, parents=[])
      style_definition_hash.each do |key, value|
        map[parents.last] ||= {} if parents.any?

        case value
        when Hash
          populate_map(value, parents + [key.to_sym])
        else
          property_name = property_name_translator ? property_name_translator.translate(key) : key.to_sym

          if parents.any?
            map[parents.last][property_name] ||= []
            map[parents.last][property_name] << { :value => value, :parents => parents.take(parents.size - 1) }
          else
            default_values[property_name] = value
          end
        end
      end
    end

    def matching_style_definitions(*tag_names_chain, property_name)
      return [] if tag_names_chain.none?

      tag_name         = tag_names_chain.last
      parent_tag_names = tag_names_chain.take(tag_names_chain.length-1)

      matching = ((map[tag_name] || {})[property_name] ||= []).select do |style_definitions|
        AnsiChameleon::ArrayUtils.includes_other_array_items_in_order?(parent_tag_names, style_definitions[:parents])
      end

      if matching.none? and tag_names_chain.any?
        matching_style_definitions(*(tag_names_chain.take(tag_names_chain.size - 1)), property_name)
      else
        matching
      end
    end

    def strongest_style_definition(*tag_names_chain, property_name)
      matching_style_definitions(*tag_names_chain, property_name).max_by { |style_definitions| style_definitions[:parents].size }
    end
  end
end
