require 'matrix'
require 'kaleidoscope/point'

module Kaleidoscope
  class Transformation
    def initialize
      @matrix = Matrix.identity(3)
    end

    def translate(dx, dy)
      translation = Matrix[[1, 0, dx], [0, 1, dy], [0, 0, 1]]
      @matrix = translation * @matrix
      self
    end

    def rotate(theta)
      cos, sin = Math.cos(theta), Math.sin(theta)
      rotation = Matrix[[cos, -sin, 0], [sin, cos, 0], [0, 0, 1]]
      @matrix = rotation * @matrix
      self
    end

    def apply(point)
      vector = Matrix.column_vector([point.x, point.y, 1])
      result = @matrix * vector
      Point.new(result[0,0], result[1,0])
    end
  end
end
