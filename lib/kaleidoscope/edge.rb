module Kaleidoscope
  class Edge
    attr_reader :p1, :p2

    def initialize(p1, p2)
      @p1, @p2 = p1, p2
      @inside = true
    end

    def length
      @length ||= Math.sqrt((@p2.x - @p1.x)**2 + (@p2.y - @p1.y)**2)
    end

    def ==(e)
      (@p1 == e.p1 && @p2 == e.p2) || (@p2 == e.p1 && @p1 == e.p2)
    end
    alias eql? ==

    def hash
      @hash ||= [@p1.hash, @p2.hash].sort.hash
    end

    def to_s
      "%s-%s" % [@p1, @p2]
    end

    def outside!
      @inside = false
    end

    def inside?
      @inside
    end
  end
end
