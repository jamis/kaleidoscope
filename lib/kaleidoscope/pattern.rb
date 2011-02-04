require 'kaleidoscope/tile'
require 'kaleidoscope/edge'
require 'kaleidoscope/transformation'
require 'kaleidoscope/polygon'

module Kaleidoscope
  class Pattern
    attr_reader :polygons, :edges

    def initialize(p, q, u=nil, v=nil)
      @tile = Tile.new(p, q, u, v)
      @polygons = []
      @edges = []
      @poly_map = {}
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

    def generate!
      edge_map = {}

      seen = {}
      seeds = [ Point.new(0, 0) ]

      while seeds.any?
        seed = seeds.pop
        next if seen[seed]
        seen[seed] = true

        @tile.phase_count.times do |n|
          data = @tile.phase(n)

          data[:polygons].each do |center, edges|
            valid_edges = {}
            inside = true

            edges.each do |edge, neighbor|
              p1 = edge.p1.translate(seed.x, seed.y)
              p2 = edge.p2.translate(seed.x, seed.y)

              p1_in = yield(p1)
              p2_in = yield(p2)

              if p1_in || p2_in
                edge = Edge.new(p1, p2)
                edge = (edge_map[edge] ||= edge)

                inside &= p1_in && p2_in
                edge.outside! unless p1_in && p2_in

                valid_edges[edge] = neighbor.translate(seed.x, seed.y)
              end
            end

            if valid_edges.any?
              poly = (@poly_map[center.translate(seed.x, seed.y)] ||= Polygon.new)
              poly.outside! unless inside
              valid_edges.each { |edge, neighbor| poly.edges[edge] = neighbor }
            end

            neighbor = data[:neighbor].translate(seed.x, seed.y)
            seeds << neighbor if yield(neighbor)
          end
        end
      end

      @edges = edge_map.keys
      @polygons = @poly_map.values
    end
  end
end
