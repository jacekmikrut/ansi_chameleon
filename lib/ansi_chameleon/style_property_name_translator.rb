module AnsiChameleon
  module StylePropertyNameTranslator

    def self.translate(property_name)
      case property_name.to_sym

      when :bold_text, :bold, :bright_text, :bright
        :bold_text

      when :underlined_text, :underlined, :underline
        :underlined_text

      when :blinking_text, :blinking, :blink
        :blinking_text

      when :reverse_video_text, :reverse_video
        :reverse_video_text

      when :background_color, :background, :bg_color
        :background_color

      when :foreground_color, :foreground, :fg_color
        :foreground_color

      end
    end
  end
end
