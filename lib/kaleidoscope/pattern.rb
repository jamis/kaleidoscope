require 'kaleidoscope/triangle'
require 'kaleidoscope/edge'
require 'kaleidoscope/transformation'

module Kaleidoscope
  class Pattern
    attr_reader :triangle, :corner, :u, :v

    def initialize(p, q, corner, u=nil, v=nil)
      @triangle = Triangle.new(p, q)
      @corner = corner

      if u.nil? || v.nil?
        @u, @v = @triangle.incenter
      else
        @u, @v = u, v
      end
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

      p1 = @triangle.at(0,0)
      p2 = @triangle.at(1,0)
      p3 = @triangle.at(0,1)
      p1, p2, p3 = [p1, p2, p3].map { |p| @triangle.reflect(flip_axis, p) } if flip_axis

      data[:vertices] = [p1, p2, p3].map { |p| transform.apply(p) }

      data[:edges] = {}

      p1 = @triangle.reflect(:p, uv)
      p2 = @triangle.reflect(:q, uv)
      p3 = @triangle.reflect(:r, uv)
      p1, p2, p3 = [p1, p2, p3].map { |p| @triangle.reflect(flip_axis, p) } if flip_axis

      e1 = Edge.new(data[:uv], transform.apply(p1))
      e2 = Edge.new(data[:uv], transform.apply(p2))
      e3 = Edge.new(data[:uv], transform.apply(p3))

      data[:edges][e1] = [data[:vertices][0], data[:vertices][2]] if e1.length > 0
      data[:edges][e2] = [data[:vertices][0], data[:vertices][1]] if e2.length > 0
      data[:edges][e3] = [data[:vertices][1], data[:vertices][2]] if e3.length > 0

      data
    end
  end
end
