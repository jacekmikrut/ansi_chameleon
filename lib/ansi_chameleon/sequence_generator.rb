module AnsiChameleon
  module SequenceGenerator

    class InvalidColorValueError  < ArgumentError; end
    class InvalidEffectValueError < ArgumentError; end

    COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]

    NUMBER_FROM_0_TO_255 = proc { |value| value.to_s =~ /^\d+$/ && (0..255).member?(value.to_i) }
    VALID_COLOR_NAME     = proc { |value| COLORS.include?(value.to_s.to_sym) }

    ON = proc { |value| [:on, :yes, true].include?(value) }

    def self.generate(style)
      "\033[0m" + style.map { |name, value| send("#{name}_sequence", value) }.join
    end

    def self.bold_text_sequence(value)
      case value
      when ON then "\033[1m"
      else raise InvalidEffectValueError.new("Invalid effect value #{value.inspect}")
      end
    end

    def self.underlined_text_sequence(value)
      case value
      when ON then "\033[4m"
      else raise InvalidEffectValueError.new("Invalid effect value #{value.inspect}")
      end
    end

    def self.blinking_text_sequence(value)
      case value
      when ON then "\033[5m"
      else raise InvalidEffectValueError.new("Invalid effect value #{value.inspect}")
      end
    end

    def self.reverse_video_text_sequence(value)
      case value
      when ON then "\033[7m"
      else raise InvalidEffectValueError.new("Invalid effect value #{value.inspect}")
      end
    end

    def self.foreground_color_sequence(value)
      case value
      when NUMBER_FROM_0_TO_255
        "\033[38;5;#{value}m"

      when VALID_COLOR_NAME
        "\033[#{COLORS.index(value.to_sym) + 30}m"

      else
        raise InvalidColorValueError.new("Invalid foreground color value #{value.inspect}")

      end
    end

    def self.background_color_sequence(value)
      case value
      when NUMBER_FROM_0_TO_255
        "\033[48;5;#{value}m"

      when VALID_COLOR_NAME
        "\033[#{COLORS.index(value.to_sym) + 40}m"

      else
        raise InvalidColorValueError.new("Invalid background color value #{value.inspect}")

      end
    end
  end
end
