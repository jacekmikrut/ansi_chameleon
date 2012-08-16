module AnsiChameleon
  class Tag

    def initialize(attrs={})
      self.name   = attrs[:name]
      self.parent = attrs[:parent]
    end

    attr_accessor :parent
    attr_reader :name

    def name=(value)
      @name = value && value.to_s
    end

    def ==(other)
      return false if other.nil?
      name == other.name && parent == other.parent
    end
  end
end
