require 'kaleidoscope/triangle'
require 'kaleidoscope/edge'
require 'kaleidoscope/point'
require 'kaleidoscope/transformation'

module Kaleidoscope
  class Tile
    attr_reader :triangle, :u, :v
    attr_reader :edges, :polygons, :colors

    def initialize(p, q, u=nil, v=nil)
      @triangle = Triangle.new(p, q)

      if u && v
        @u, @v = u, v
      else
        @u, @v = @triangle.incenter
      end

      build_polygons!
    end

    def phase_angle
      @phase_angle = @triangle.p_theta * 2
    end

    def phase_count
      @triangle.p
    end

    def phase(n)
      t = Transformation.new
      t.translate(-@triangle.q_length, 0)
      t.rotate(phase_angle * n) if n != 0

      data = { :edges => [], :polygons => {}, :colors => {} }

      edge_map = {}
      @edges.each do |edge|
        e = Edge.new(t.apply(edge.p1), t.apply(edge.p2))
        data[:edges] << e
        edge_map[edge] = e
      end

      @polygons.each do |center, edges|
        c1 = t.apply(center)
        data[:colors][c1] = @colors[center]
        data[:polygons][c1] = edges.inject({}) do |hash, (e, c)|
          hash[edge_map[e]] = t.apply(c)
          hash
        end
      end

      data[:neighbor] = t.apply(Point.new(-@triangle.q_length, 0))

      data
    end

    private

      #         h                 p6            p5
      #    \    :    /              e6        e5
      #     \ __:__ /                 p2 e1 p1
      #      |  :  |
      # i----|--c--|----g             e2    e4
      #      |__:__|
      #     /   :   \                 p3 e3 p4
      #    /    :    \              e7        e8
      #         j                 p7            p8
      #       
      def build_polygons!
        # polygon center points
        c = Point.new(0,0)
        g = @triangle.at(1, 0)
        h = @triangle.at(0, 1)
        i = @triangle.at(-1, 0)
        j = @triangle.at(0, -1)

        # edge end-points
        p1 = @triangle.at(@u, @v)
        p2 = Point.new(-p1.x, p1.y)
        p3 = Point.new(-p1.x, -p1.y)
        p4 = Point.new(p1.x, -p1.y)

        p5 = @triangle.reflect(:r, p1)
        p6 = Point.new(-p5.x, p5.y)
        p7 = Point.new(-p5.x, -p5.y)
        p8 = Point.new(p5.x, -p5.y)

        # edges
        e1 = Edge.new(p1, p2)
        e2 = Edge.new(p2, p3)
        e3 = Edge.new(p3, p4)
        e4 = Edge.new(p4, p1)
        e5 = Edge.new(p1, p5)
        e6 = Edge.new(p2, p6)
        e7 = Edge.new(p3, p7)
        e8 = Edge.new(p4, p8)

        # polygon edge maps
        edge_map = {
          c => { e1 => h, e2 => i, e3 => j, e4 => g },
          g => { e4 => c, e5 => h, e8 => j },
          h => { e1 => c, e5 => g, e6 => i },
          i => { e2 => c, e6 => h, e7 => j },
          j => { e3 => c, e7 => i, e8 => g }
        }

        # polygon color map
        color_map = { c => 0, g => 1, h => 2, i => 1, j => 2 }

        edges = {}

        center_ok = proc { |list| list.include?(e1) && list.include?(e2) }
        other_ok = proc { |list| list.any? }

        # constraints for the polygons to ensure that they are not degenerate
        constraints = {
          c => center_ok,
          g => other_ok, h => other_ok, i => other_ok, j => other_ok
        }

        @polygons = {}
        @colors = {}

        edge_map.each do |center, map|
          keepers = map.keys.select { |e| e.length.abs > 0.001 }
          if constraints[center][keepers]
            @polygons[center] = {}
            @colors[center] = color_map[center]
            keepers.each do |edge|
              edges[edge] = true
              @polygons[center][edge] = map[edge]
            end
          end
        end

        @edges = edges.keys
      end
  end
end
