module Kaleidoscope
  class PointDictionary
    def initialize
      @map = {}
    end

    def canonical(point)
      x, y = (point.x * 10).round, (point.y * 10).round
      key = x * 100_000 + y
      @map[key] ||= point
    end
  end
end
