module AnsiChameleon
  module StylePropertyNameTranslator

    def self.translate(property_name)
      case property_name

      when :background_color, :background, :bg_color
        :background_color_name

      when :foreground_color, :foreground, :fg_color
        :foreground_color_name

      when :effect
        :effect_name

      end
    end
  end
end
