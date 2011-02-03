require 'kaleidoscope/point'

module Kaleidoscope
  #  Defines a right triangle with a hypotenuse of length 1. The parameters
  #  p and q are divisors of PI representing the angle at the given corners,
  #  e.g. theta(p) = PI/p, theta(q) = PI/q. "r" is always 2, and is not
  #  modifiable in this implementation.
  #
  #   q
  #   |\
  #   | \
  #   |  \R
  #  P|v  \
  #   |    \
  #   |__u__\
  #  r   Q   p
  #
  # r, q, and p are angles (r being a right angle)
  # R, Q, and P are lengths
  # u and v indicate the axis those coordinates apply to

  class Triangle
    RIGHT = Math::PI / 2

    attr_reader :p, :q

    def initialize(p, q)
      @p, @q = p, q

      @p_theta = Math::PI / @p
      @q_theta = Math::PI / @q
    end

    def angle_at(corner)
      case corner
        when :p then @p_theta
        when :q then @q_theta
        when :r then RIGHT
      end
    end

    def value(name)
      case name
      when :p then @p
      when :q then @q
      when :r then 2
      end
    end

    def p_length  
      @p_length ||= Math.sin(@p_theta)
    end

    def q_length
      @q_length ||= Math.sin(@q_theta)
    end

    def slope
      @slope ||= -p_length / q_length
    end

    def incenter
      @incenter ||= begin
        circ = p_length + q_length + 1
        [p_length / circ, q_length / circ].freeze
      end
    end

    # The math for these mirror functions goes something like this. Given a right
    # triangle as described above, we want to mirror the origin (the point at r)
    # across the hypotenuse, R. We do this by drawing a line perpendicular to R
    # from the origin, which happens to create a smaller version of the overall
    # triangle, rotated so that the hypotenuse of the new triangle is Q.
    #
    # Since the angles of the new triangle are identical, we know that R/P = Q/P2, 
    # where P2 is the perpendicular line we just drew. Solving for P2 we see that
    # P2 = PQ/R. And since R is always 1.0 in this implementation, we can drop it
    # altogether.
    #
    # Similarly, R/Q = Q/Q2, which yields Q2 = Q^2.
    #
    # Now we know the how far the origin is from the hypotenuse, but we want to
    # actually find the coordinate where the hypotenuse and P2 intersect. (P2,
    # remember, is the perpendular line we added). To do this, we need to further
    # subdivide the new triangle by dropping a line from that intersection point
    # to Q. But this is the same problem we just solved, only with P2 as the
    # hypotenuse instead of R. So we can plug in the same equations as before:
    #
    #   R/P = P2/P3, which gives (after dropping R) P3 = QP^2
    #   R/Q = P2/Q3, which gives Q3 = PQ^2
    #
    # P3 is the x offset, then, from the origin to the intersection point, and
    # Q3 is the y offset. Doubling those values gives us the reflected value.
    def mirror_x
      @mirror_x ||= 2 * q_length * p_length * p_length
    end

    def mirror_y
      @mirror_y ||= 2 * p_length * q_length * q_length
    end

    def at(u, v)
      # = p * u + q * v + r * w
      #   but r is (0,0), so w is not needed
      #
      # x = px * v + qx * u
      #     but px is 0, so that term drops out
      # 
      # y = py * v + qy * u
      #     but qy is 0, so that term drops out
      #
      # note that if u+v == 1, the point is on
      # the hypotenuse.
      #
      # also, note that unless 0 >= u + v + w <= 1,
      # the point will be outside the triangle.

      x = q_length * u # q_length is the x-coordinate of p
      y = p_length * v # p_length is the y-coordinate of q

      Point.new(x, y)
    end

    def reflect(side, point)
      case side
      when :p then Point.new(-point.x, point.y)
      when :q then Point.new(point.x, -point.y)
      when :r then
        x = (point.y - p_length) / slope
        dx = x - point.x
        scale = q_length / dx

        Point.new(point.x + mirror_x / scale, point.y + mirror_y / scale)
      end
    end
  end
end
