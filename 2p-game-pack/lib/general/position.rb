module GamePack2P
  class Position
    attr_accessor :x
    attr_accessor :y

    def initialize(x, y)
      @x = x
      @y = y
    end
  end
end