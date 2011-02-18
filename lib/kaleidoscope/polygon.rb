module Kaleidoscope
  # A Polygon consists of a set of edges, a center point, and a color.
  #
  # The center point uniquely identifies this polygon, as no other
  # polygon will ever share that center point within the same pattern.
  #
  # The color value is simply an integer that can be used to identify
  # which color "set" the polygon belongs to; an application can use
  # this value to determine how the polygon ought to be colored.
  class Polygon
    attr_reader :master, :center, :color
    attr_reader :edge_map

    def initialize(master, center, color=nil)
      @master = master
      @center = center
      @color = color

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

    # Returns the polygon on the other side of the given edge.
    def neighbor_via(edge)
      point = @edge_map[edge]
      @master.polygon_at(point)
    end
  end
end
