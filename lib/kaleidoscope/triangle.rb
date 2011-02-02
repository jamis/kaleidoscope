module Kaleidoscope
  #  Defines a right triangle with a hypotenuse of length 1. The parameters
  #  p and q are divisors of PI representing the angle at the given corners,
  #  e.g. theta(p) = PI/p, theta(q) = PI/q. "r" is always 2, and is not
  #  modifiable in this implementation.
  #
  #   p
  #   |\
  #   | \
  #   |  \R
  #  Q|v  \
  #   |    \
  #   |__u__\
  #  r   P   q
  #
  # r, q, and p are angles (r being a right angle)
  # R, Q, and P are lengths
  # u and v indicate the axis those coordinates apply to

  class Triangle
    attr_reader :p, :q

    def initialize(p, q)
      @p, @q = p, q

      @p_theta = Math::PI / @p
      @q_theta = Math::PI / @q
    end

    def p_length  
      @p_length ||= Math.sin(@p_theta)
    end

    def q_length
      @q_length ||= Math.sin(@q_theta)
    end

    def slope
      @slope ||= -q_length / p_length
    end

    # The math for these mirror functions goes something like this. Given a right
    # triangle as described above, we want to mirror the origin (the point at r)
    # across the hypotenuse, R. We do this by drawing a line perpendicular to R
    # from the origin, which happens to create a smaller version of the overall
    # triangle, rotated so that the hypotenuse of the new triangle is P.
    #
    # Since the angles of the new triangle are identical, we know that R/P = Q/Q2, 
    # where Q2 is the perpendicular line we just drew. Solving for Q2 we see that
    # Q2 = PQ/R. And since R is always 1.0 in this implementation, we can drop it
    # altogether.
    #
    # Similarly, R/Q = Q/P2, which yields P2 = Q^2.
    #
    # Now we know the how far the origin is from the hypotenuse, but we want to
    # actually find the coordinate where the hypotenuse and Q2 intersect. (Q2,
    # remember, is the perpendular line we added). To do this, we need to further
    # subdivide the new triangle by dropping a line from that intersection point
    # to P. But this is the same problem we just solved, only with P as the
    # hypotenuse instead of R. So we can plug in the same equations as before:
    #
    #   P/Q2 = Q2/Q3, which gives Q3 = Q2*Q2/P.
    #     Substituting PQ for Q2 we get Q3 = PQPQ/P, or Q3 = PQ^2
    #
    # Solve similarly for P3.
    #
    # Q3 is the x offset, then, from the origin to the intersection point, and
    # P3 is the y offset. Doubling those values gives us the reflected value.
    def mirror_x
      @mirror_x ||= 2 * p_length * q_length * q_length
    end

    def mirror_y
      @mirror_y ||= 2 * q_length * p_length * p_length
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

      x = p_length * u # p_length is the x-coordinate of q
      y = q_length * v # q_length is the y-coordinate of p

      [x, y]
    end

    def reflect(side, x, y)
      case side
      when :p then [-x, y]
      when :q then [x, -y]
      when :r then
        x2 = (y - q_length) / slope
        y2 = slope * x + q_length
        dx, dy = x2 - x, y2 - y
        scale = p_length / dx

        [x + mirror_x / scale, y + mirror_y / scale]
      end
    end
  end
end
