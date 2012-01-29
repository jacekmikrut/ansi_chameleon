module AnsiChameleon
  class StyleSheetHandler

    def initialize(style_sheet_hash, property_name_translator=nil)
      @tag_names = []
      @default_values = {}
      @map = {}
      @property_name_translator = property_name_translator
      populate_map(style_sheet_hash)
    end

    attr_reader :tag_names, :default_values, :map, :property_name_translator

    def value_for(*tag_names_chain, property_name)
      strongest = strongest_style_definition(*(tag_names_chain.map { |tag_name| tag_name.to_sym }), property_name.to_sym)
      strongest && strongest[:value]
    end

    private

    def populate_map(style_definition_hash, tag_names_chain=[])
      style_definition_hash.each do |key, value|

        case value
        when Hash
          tag_name = key.to_sym

          @tag_names << tag_name unless @tag_names.include?(tag_name)
          populate_map(value, tag_names_chain + [tag_name])

        else
          property_name = property_name_translator ? property_name_translator.translate(key) : key.to_sym

          @map[property_name] ||= []
          @map[property_name] << { :value => value, :tag_names_chain => tag_names_chain }
          @default_values[property_name] = value if tag_names_chain.none?

        end
      end
    end

    def strongest_style_definition(*tag_names_chain, property_name)
      (@map[property_name] || [])
        .map { |entry|
          entry.merge(:item_spread_map => AnsiChameleon::ArrayUtils.item_spread_map(tag_names_chain, entry[:tag_names_chain])) }
        .select { |entry|
          not entry[:item_spread_map].nil? }
        .compact
        .max_by { |entry|
          entry[:item_spread_map].reverse }
    end
  end
end
