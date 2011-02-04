module Kaleidoscope
  class Point
    NORMALIZER = 1000

    attr_reader :x, :y
    attr_reader :xi, :yi

    def initialize(x, y)
      @x, @y = x, y
      @xi, @yi = (x * NORMALIZER).round, (y * NORMALIZER).round
    end

    def translate(dx, dy)
      Point.new(@x + dx, @y + dy)
    end

    def to_s
      "(%g,%g)" % [@x, @y]
    end

    def ==(pt)
      pt && xi == pt.xi && yi == pt.yi
    end
    alias eql? ==

    def hash
      @hash ||= [@xi, @yi].hash
    end
  end
end
