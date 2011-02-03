require 'kaleidoscope/triangle'
require 'kaleidoscope/edge'
require 'kaleidoscope/transformation'
require 'kaleidoscope/polygon'

module Kaleidoscope
  class Pattern
    attr_reader :triangle, :corner, :u, :v

    attr_reader :polygons, :edges

    def initialize(p, q, corner, u=nil, v=nil)
      @triangle = Triangle.new(p, q)
      @corner = corner

      case @corner
        when :p then @neighbors = [:q]
        when :q then @neighbors = [:p]
        else @neighbors = [:p, :q]
      end

      if u.nil? || v.nil?
        @u, @v = @triangle.incenter
      else
        @u, @v = u, v
      end

      @polygons = {}
      @edges = {}
    end

    def add_edge(edge)
      @edges[edge] ||= edge
    end

    def polygon_at(point)
      @polygons[point] ||= Polygon.new
    end

    def build_at(point)
      neighbors = {}

      (@triangle.value(@corner) * 2).times do |n|
        data = apply(n, point)

        data[:neighbors].each do |neighbor|
          if !block_given? || yield(neighbor)
            neighbors[neighbor] = true
          end
        end

        data[:edges].each do |edge, centers|
          c1, c2 = centers # should always be two centers for each edge, one on each side

          if block_given?
            p1_in = yield(edge.p1)
            p2_in = yield(edge.p2)
          else
            p1_in = p2_in = true
          end

          if p1_in && p2_in
            edge = add_edge(edge)

            poly1 = polygon_at(c1)
            poly2 = polygon_at(c2)

            poly1.edges[edge] = poly2
            poly2.edges[edge] = poly1
          elsif p1_in || p2_in # edge is partially out-of-bounds
            polygon_at(c1).outside!
            polygon_at(c2).outside!
          else
            # we totally ignore this edge and any associated polygons
          end
        end
      end

      neighbors.keys
    end

    def apply(n, point)
      data = {}

      transform = Transformation.new

      case @corner
      when :p then transform.translate(-@triangle.q_length, 0)
      when :q then transform.translate(0, -@triangle.p_length)
      end

      if n % 2 == 1
        flip_axis = case @corner
          when :r then :p
          when :p then :q
          when :q then :r
          else abort "no #{@corner}"
        end

        transform.rotate(@triangle.angle_at(@corner) * (n - 1))
      else
        transform.rotate(@triangle.angle_at(@corner) * n)
      end

      transform.translate(point.x, point.y)

      data[:uv] = uv = @triangle.at(@u, @v)
      data[:uv] = @triangle.reflect(flip_axis, data[:uv]) if flip_axis
      data[:uv] = transform.apply(data[:uv])

      r, p, q = @triangle.at(0,0), @triangle.at(1,0), @triangle.at(0,1)
      r, p, q = [r, p, q].map { |pt| @triangle.reflect(flip_axis, pt) } if flip_axis
      r, p, q = [r, p, q].map { |pt| transform.apply(pt) }

      data[:vertices] = [r, p, q]

      data[:edges] = {}

      p1 = @triangle.reflect(:p, uv)
      p2 = @triangle.reflect(:q, uv)
      p3 = @triangle.reflect(:r, uv)
      p1, p2, p3 = [p1, p2, p3].map { |pt| @triangle.reflect(flip_axis, pt) } if flip_axis

      e1 = Edge.new(data[:uv], transform.apply(p1))
      e2 = Edge.new(data[:uv], transform.apply(p2))
      e3 = Edge.new(data[:uv], transform.apply(p3))

      data[:edges][e1] = [data[:vertices][0], data[:vertices][2]] if e1.length > 0
      data[:edges][e2] = [data[:vertices][0], data[:vertices][1]] if e2.length > 0
      data[:edges][e3] = [data[:vertices][1], data[:vertices][2]] if e3.length > 0

      corners = { :r => r, :p => p, :q => q }

      data[:neighbors] = @neighbors.map do |v|
        from = corners[@corner]
        to = corners[v]

        x = from.x + 2 * (to.x - from.x)
        y = from.y + 2 * (to.y - from.y)

        Point.new(x, y)
      end

      data
    end
  end
end
