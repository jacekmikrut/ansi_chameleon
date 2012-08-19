module AnsiChameleon
  class Tag

    NAME_FIRST_CHAR_REG = "[_a-zA-Z]"
    NAME_OTHER_CHARS_REG = "\\w*"
    NAME_REG = NAME_FIRST_CHAR_REG + NAME_OTHER_CHARS_REG

    def initialize(attrs={})
      self.name            = attrs[:name]
      self.id              = attrs[:id]
      self.class_names     = attrs[:class_names]
      self.parent          = attrs[:parent]
      self.original_string = attrs[:original_string]
    end

    attr_accessor :parent
    attr_reader :name, :id, :class_names, :original_string

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
