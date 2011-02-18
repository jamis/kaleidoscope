require 'kaleidoscope/tile'
require 'kaleidoscope/edge'
require 'kaleidoscope/transformation'
require 'kaleidoscope/polygon'
require 'kaleidoscope/point_dictionary'

module Kaleidoscope
  # The Pattern class is the primary means of generating patterns. You
  # instantiate a pattern by providing the p and q values for the
  # desired fundamental triangles, and optionally the u and v values
  # for the generator point.
  #
  #   pattern = Kaleidoscope::Pattern.new(6, 3, 0.35, 0.65)
  #   pattern.generate! do |point|
  #     point.x * point.x + point.y * point.y < 10
  #   end
  #
  #   pattern.polygons.each do |polygon|
  #     # ...
  #   end
  #
  # Note that the generated pattern will include all the polygons
  # within the specified region (naturally), but will also include
  # the polygons that lie immediately outside the region, too.
  # (This is to aid some applications in consistently identifying
  # the boundary of the pattern.) You can identify the inside/outside
  # polygons via the Polygon#inside? method.
  class Pattern
    # Instantiates a new pattern with the given fundamental triangle
    # (p,q,2), and the given (u,v) generator point. If the generator
    # point is not given, it will default to the incenter of the
    # fundamental triangle.
    def initialize(p, q, u=nil, v=nil)
      @tile = Tile.new(p, q, u, v)
      @polygons = @edges = nil
      @poly_map = {}
      @edge_map = {}
      @dict = PointDictionary.new
    end

    def u
      @tile.u
    end

    def v
      @tile.v
    end

    def p
      @tile.triangle.p
    end

    def q
      @tile.triangle.q
    end

    def polygon_at(point)
      @poly_map[point]
    end

    # Returns all of the polygons defined in the pattern.
    def polygons
      @polygons || @poly_map.values
    end

    # Returns all of the edges defined in the pattern.
    def edges
      @edges || @edge_map.keys
    end

    def build_at(seed, increment, &validator)
      trans = Transformation.new
      if increment % 2 == 1 && @tile.triangle.p % 2 == 1
        trans.rotate(@tile.triangle.p_theta)
      end
      trans.translate(seed.x, seed.y)

      validator ||= proc { |pt| true }
      seeds = []
      valid_edges_generated = false

      @tile.phase_count.times do |n|
        data = @tile.phase(n)

        data[:polygons].each do |center, edges|
          valid_edges = {}
          inside = true

          edges.each do |edge, neighbor|
            p1 = @dict.canonical(trans.apply(edge.p1))
            p2 = @dict.canonical(trans.apply(edge.p2))

            p1_in = validator[p1]
            p2_in = validator[p2]

            if p1_in || p2_in
              edge = Edge.new(p1, p2)
              edge = (@edge_map[edge] ||= edge)

              inside &= p1_in && p2_in
              edge.outside! unless p1_in && p2_in

              valid_edges[edge] = @dict.canonical(trans.apply(neighbor))
            end
          end

          if valid_edges.any?
            color = data[:colors][center]
            center = @dict.canonical(trans.apply(center))
            poly = (@poly_map[center] ||= Polygon.new(self, center, color))
            poly.outside! unless inside
            valid_edges.each { |edge, neighbor| poly.edge_map[edge] = neighbor }
            valid_edges_generated = true
          end
        end

        seeds << @dict.canonical(trans.apply(data[:neighbor])) if valid_edges_generated
      end

      return seeds
    end

    # Generates the pattern by building out the polygons as needed to
    # tesselate the plane. The validator block is invoked for every point
    # to determine whether the point lies within the desired region of the
    # plane or not.
    def generate!(&validator)
      seen = {}
      seeds = [ [0, Point.new(0, 0)] ]

      @edges = @polygons = nil
      @edge_map.clear
      @poly_map.clear

      while seeds.any?
        generation, seed = seeds.pop

        next if seen[seed]
        seen[seed] = true

        neighbors = build_at(seed, generation, &validator)

        neighbors.each do |point|
          next if seen[point]
          seeds << [generation+1, point]
        end
      end

      @edges = @edge_map.keys
      @polygons = @poly_map.values
    end
  end
end
