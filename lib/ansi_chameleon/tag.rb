module AnsiChameleon
  class Tag

    NAME_FIRST_CHAR_REG = "[_a-zA-Z]"
    NAME_OTHER_CHARS_REG = "\\w*"
    NAME_REG = NAME_FIRST_CHAR_REG + NAME_OTHER_CHARS_REG

       ID_REG = %{id=(?<id_quote>["'])(?<id>(?:(?!\\g<id_quote>).)*)\\g<id_quote>}
    CLASS_REG = %{class=(?<class_quote>["'])(?<class>(?:(?!\\g<class_quote>).)*)\\g<class_quote>}

    def self.parse(string)
      if m = string.match(/\A<(?<closing_char>\/)?(?<name>#{NAME_REG})(?:#{ID_REG}|#{CLASS_REG}|.)*>\z/)
        new(
          :closing         => !!m[:closing_char],
          :name            => m[:name],
          :id              => m[:id],
          :class_names     => m[:class] && m[:class].scan(/\S+/),
          :original_string => string
        )
      end
    end

    def initialize(attrs={})
      self.closing         = attrs[:closing]
      self.name            = attrs[:name]
      self.id              = attrs[:id]
      self.class_names     = attrs[:class_names]
      self.parent          = attrs[:parent]
      self.original_string = attrs[:original_string]
    end

    attr_accessor :parent
    attr_reader :name, :id, :class_names, :original_string
    attr_writer :closing

    def closing?
      @closing
    end

    def opening?
      !closing?
    end

    def name=(value)
      @name = value && value.to_s
    end

    def id=(value)
      @id = value && value.to_s
    end

    def class_names=(array)
      @class_names = array && array.map(&:to_s) || []
    end

    def ==(other)
                         !other.nil? &&
                  name == other.name &&
                    id == other.id &&
      class_names.sort == other.class_names.sort &&
                parent == other.parent
    end

    private

    attr_writer :original_string

  end
end
