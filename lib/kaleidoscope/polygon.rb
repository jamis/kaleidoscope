module Kaleidoscope
  class Polygon
    attr_reader :edges

    def initialize
      @edges = {}
      @inside = true
    end

    def inside?
      @inside
    end

    def outside!
      @inside = false
    end
  end
end
