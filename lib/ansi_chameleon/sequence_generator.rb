module AnsiChameleon
  module SequenceGenerator

    class UnknownColorValue  < ArgumentError; end
    class UnknownEffectValue < ArgumentError; end

    COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    EFFECTS = { :none => 0, :bright => 1, :underline => 4, :blink => 5, :reverse => 7 }

    def self.generate(effect_value, foreground_color_value=nil, background_color_value=nil)
      if effect_value.to_sym == :reset
        "\033[0m"
      else
        "#{effect_sequence(effect_value)}#{foreground_color_sequence(foreground_color_value)}#{background_color_sequence(background_color_value)}"
      end
    end

    def self.effect_sequence(value)
      if EFFECTS.include?(value.to_sym)
        "\033[#{EFFECTS[value.to_sym]}m"

      else
        raise UnknownEffectValue.new("Unknown effect value #{value.inspect}")

      end
    end

    def self.foreground_color_sequence(value)
      if number_from_0_to_255?(value)
        "\033[38;5;#{value}m"

      elsif COLORS.include?(value.to_s.to_sym)
        "\033[#{COLORS.index(value.to_sym) + 30}m"

      else
        raise UnknownColorValue.new("Unknown foreground color value #{value.inspect}")

      end
    end

    def self.background_color_sequence(value)
      if number_from_0_to_255?(value)
        "\033[48;5;#{value}m"

      elsif COLORS.include?(value.to_s.to_sym)
        "\033[#{COLORS.index(value.to_sym) + 40}m"

      else
        raise UnknownColorValue.new("Unknown background color value #{value.inspect}")

      end
    end

    def self.number_from_0_to_255?(value)
      value.to_s =~ /^\d+$/ && (0..255).member?(value.to_i)
    end
  end
end
