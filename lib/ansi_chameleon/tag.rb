module AnsiChameleon
  class Tag

    def initialize(attrs={})
      self.name   = attrs[:name]
      self.parent = attrs[:parent]
    end

    attr_accessor :name, :parent

  end
end
