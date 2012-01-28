module AnsiChameleon
  module SequenceGenerator

    class UnknownColorName  < ArgumentError; end
    class UnknownEffectName < ArgumentError; end

    COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    EFFECTS = { :none => 0, :bright => 1, :underline => 4, :blink => 5, :reverse => 7 }

    def self.effect_code(name)
      EFFECTS[name.to_sym] or raise UnknownEffectName.new("Unknown effect name #{name.inspect}")
    end

    def self.foreground_color_code(name)
      index = COLORS.index(name.to_sym) or raise UnknownColorName.new("Unknown foreground color name #{name.inspect}")
      30 + index
    end

    def self.background_color_code(name)
      index = COLORS.index(name.to_sym) or raise UnknownColorName.new("Unknown background color name #{name.inspect}")
      40 + index
    end

    def self.generate(effect_name, foreground_color_name=nil, background_color_name=nil)
      if effect_name.to_sym == :reset
        "\033[0m"
      else
        "\033[#{effect_code(effect_name)};#{foreground_color_code(foreground_color_name)};#{background_color_code(background_color_name)}m"
      end
    end
  end
end
