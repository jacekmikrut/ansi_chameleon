module AnsiChameleon
  module SequenceGenerator

    class InvalidColorValueError  < ArgumentError; end
    class InvalidEffectValueError < ArgumentError; end

    COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    EFFECTS = { :none => 0, :bright => 1, :underline => 4, :blink => 5, :reverse => 7 }

    NUMBER_FROM_0_TO_255 = proc { |value| value.to_s =~ /^\d+$/ && (0..255).member?(value.to_i) }

    def self.generate(style)
      "\033[0m" + style.map { |name, value| send("#{name}_sequence", value) }.join
    end

    def self.effect_sequence(value)
      if EFFECTS.include?(value.to_sym)
        "\033[#{EFFECTS[value.to_sym]}m"

      else
        raise InvalidEffectValueError.new("Invalid effect value #{value.inspect}")

      end
    end

    def self.foreground_color_sequence(value)
      if NUMBER_FROM_0_TO_255.call(value)
        "\033[38;5;#{value}m"

      elsif COLORS.include?(value.to_s.to_sym)
        "\033[#{COLORS.index(value.to_sym) + 30}m"

      else
        raise InvalidColorValueError.new("Invalid foreground color value #{value.inspect}")

      end
    end

    def self.background_color_sequence(value)
      if NUMBER_FROM_0_TO_255.call(value)
        "\033[48;5;#{value}m"

      elsif COLORS.include?(value.to_s.to_sym)
        "\033[#{COLORS.index(value.to_sym) + 40}m"

      else
        raise InvalidColorValueError.new("Invalid background color value #{value.inspect}")

      end
    end
  end
end
