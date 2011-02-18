module Kaleidoscope
  class Polygon
    attr_reader :master, :center
    attr_reader :edge_map

    def initialize(master, center)
      @master = master
      @center = center

      @edge_map = {}
      @inside = true
    end

    def edges
      @edge_map.keys
    end

    def inside?
      @inside
    end

    def outside!
      @inside = false
    end

    def neighbor_via(edge)
      point = @edge_map[edge]
      @master.polygon_at(point)
    end
  end
end
