require 'kaleidoscope/tile'
require 'kaleidoscope/edge'
require 'kaleidoscope/transformation'
require 'kaleidoscope/polygon'
require 'kaleidoscope/point_dictionary'

module Kaleidoscope
  class Pattern
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

    def polygons
      @polygons || @poly_map.values
    end

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
            poly = (@poly_map[@dict.canonical(trans.apply(center))] ||= Polygon.new(self))
            poly.outside! unless inside
            valid_edges.each { |edge, neighbor| poly.edge_map[edge] = neighbor }
            valid_edges_generated = true
          end
        end

        seeds << @dict.canonical(trans.apply(data[:neighbor])) if valid_edges_generated
      end

      return seeds
    end

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
