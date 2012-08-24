module AnsiChameleon
  module StylePropertyNameTranslator

    def self.translate(property_name)
      case property_name.to_sym

      when :background_color, :background, :bg_color
        :background_color

      when :foreground_color, :foreground, :fg_color
        :foreground_color

      when :effect
        :effect

      end
    end
  end
end
