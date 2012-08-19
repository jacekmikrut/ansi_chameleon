module AnsiChameleon
  class Tag

    def initialize(attrs={})
      self.name   = attrs[:name]
      self.id     = attrs[:id]
      self.parent = attrs[:parent]
      self.original_string = attrs[:original_string]
    end

    attr_accessor :parent
    attr_reader :name, :id, :original_string

    def name=(value)
      @name = value && value.to_s
    end

    def id=(value)
      @id = value && value.to_s
    end

    def ==(other)
      return false if other.nil?
      name == other.name && id == other.id && parent == other.parent
    end

    private

    attr_writer :original_string

  end
end
