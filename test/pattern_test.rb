require 'test/unit'
require 'kaleidoscope/pattern'
require 'kaleidoscope/point'
require 'kaleidoscope/edge'

class PatternTest < Test::Unit::TestCase
  include Kaleidoscope

  def test_constructor_instantiates_template_triangle_and_sets_attributes
    pattern = Pattern.new(6, 3, :p, 0.3, 0.4)
    assert_equal 6, pattern.triangle.p
    assert_equal 3, pattern.triangle.q
    assert_equal :p, pattern.corner
    assert_equal 0.3, pattern.u
    assert_equal 0.4, pattern.v
  end

  def test_apply_step_zero_for_r_at_origin_should_describe_template_triangle
    pattern = Pattern.new(6, 3, :r, 0.3, 0.4)
    origin = Point.new(0, 0)

    data = pattern.apply(0, origin)

    assert_equal 3, data[:vertices].length
    assert data[:vertices].include?(pattern.triangle.at(0,0))
    assert data[:vertices].include?(pattern.triangle.at(1,0))
    assert data[:vertices].include?(pattern.triangle.at(0,1))
  end

  def test_apply_step_zero_for_r_at_origin_should_build_edges_from_midpoint
    pattern = Pattern.new(6, 3, :r, 0.3, 0.4)
    origin = Point.new(0, 0)

    data = pattern.apply(0, origin)
    mid = pattern.triangle.at(0.3, 0.4)

    assert_equal data[:uv], mid
    assert_equal 3, data[:edges].length

    e1 = Edge.new(mid, pattern.triangle.reflect(:p, mid))
    e2 = Edge.new(mid, pattern.triangle.reflect(:q, mid))
    e3 = Edge.new(mid, pattern.triangle.reflect(:r, mid))

    assert data[:edges][e1].include?(pattern.triangle.at(0, 0))
    assert data[:edges][e1].include?(pattern.triangle.at(0, 1))

    assert data[:edges][e2].include?(pattern.triangle.at(0, 0))
    assert data[:edges][e2].include?(pattern.triangle.at(1, 0))

    assert data[:edges][e3].include?(pattern.triangle.at(1, 0))
    assert data[:edges][e3].include?(pattern.triangle.at(0, 1))
  end

  def test_apply_step_zero_for_r_at_an_offset_should_translate_all_points
    pattern = Pattern.new(6, 3, :r, 0.3, 0.4)
    origin = Point.new(7.5, -4.2)
    data = pattern.apply(0, origin)

    uv = pattern.triangle.at(0.3, 0.4)
    mid = uv.translate(origin.x, origin.y)
    assert_equal data[:uv], mid

    e1 = Edge.new(mid, pattern.triangle.reflect(:p, uv).translate(origin.x, origin.y))
    e2 = Edge.new(mid, pattern.triangle.reflect(:q, uv).translate(origin.x, origin.y))
    e3 = Edge.new(mid, pattern.triangle.reflect(:r, uv).translate(origin.x, origin.y))

    assert data[:edges].key?(e1)
    assert data[:edges].key?(e2)
    assert data[:edges].key?(e3)
  end

  def test_apply_step_one_for_r_should_flip_triangle
    pattern = Pattern.new(6, 3, :r, 0.3, 0.4)
    data = pattern.apply(1, Point.new(0, 0))

    uv = pattern.triangle.at(0.3, 0.4)
    mid = pattern.triangle.reflect(:p, uv)
    assert_equal data[:uv], mid

    p1, p2, p3 = pattern.triangle.at(0, 0), pattern.triangle.at(1, 0), pattern.triangle.at(0, 1)
    p2 = pattern.triangle.reflect(:p, p2)

    assert data[:vertices].include?(p1)
    assert data[:vertices].include?(p2)
    assert data[:vertices].include?(p3)

    e1 = Edge.new(mid, uv)
    e2 = Edge.new(mid, pattern.triangle.reflect(:p, pattern.triangle.reflect(:q, uv)))
    e3 = Edge.new(mid, pattern.triangle.reflect(:p, pattern.triangle.reflect(:r, uv)))

    assert data[:edges].key?(e1)
    assert data[:edges].key?(e2)
    assert data[:edges].key?(e3)
  end

  def test_apply_step_two_for_r_should_rotate_triangle
    pattern = Pattern.new(6, 3, :r, 0.3, 0.4)
    data = pattern.apply(2, Point.new(0, 0))

    uv = pattern.triangle.at(0.3, 0.4)
    mid = Point.new(-uv.x, -uv.y)
    assert_equal data[:uv], mid

    p1, p2, p3 = pattern.triangle.at(0, 0), pattern.triangle.at(1, 0), pattern.triangle.at(0, 1)
    p1, p2, p3 = [p1, p2, p3].map { |p| Point.new(-p.x, -p.y) }

    assert data[:vertices].include?(p1)
    assert data[:vertices].include?(p2)
    assert data[:vertices].include?(p3)

    e1 = Edge.new(mid, Point.new(uv.x, -uv.y))
    e2 = Edge.new(mid, Point.new(-uv.x, uv.y))
    p = pattern.triangle.reflect(:r, uv)
    e3 = Edge.new(mid, Point.new(-p.x, -p.y))

    assert data[:edges].key?(e1)
    assert data[:edges].key?(e2)
    assert data[:edges].key?(e3)
  end

  def test_apply_step_4_for_r_should_given_template_triangle
    pattern = Pattern.new(6, 3, :r, 0.3, 0.4)
    data = pattern.apply(4, Point.new(0, 0))

    assert_equal 3, data[:vertices].length
    assert data[:vertices].include?(pattern.triangle.at(0,0))
    assert data[:vertices].include?(pattern.triangle.at(1,0))
    assert data[:vertices].include?(pattern.triangle.at(0,1))
  end

  def test_apply_step_0_for_p_should_translate_triangle_to_p
    pattern = Pattern.new(6, 3, :p, 0.3, 0.4)
    tri = pattern.triangle
    data = pattern.apply(0, Point.new(0, 0))

    p1, p2, p3 = tri.at(0, 0), tri.at(1, 0), tri.at(0, 1)

    tform = Transformation.new
    tform.translate(-p2.x, -p2.y)

    p1, p2, p3 = [p1, p2, p3].map { |p| tform.apply(p) }

    assert_equal 3, data[:vertices].length
    assert data[:vertices].include?(p1)
    assert data[:vertices].include?(p2)
    assert data[:vertices].include?(p3)

    uv = tri.at(0.3, 0.4)
    assert_equal tform.apply(uv), data[:uv]
  end

  def test_apply_should_omit_degenerate_edges
    pattern = Pattern.new(3, 6, :r, 0, 0)
    data = pattern.apply(0, Point.new(0, 0))
    assert_equal 1, data[:edges].length
    p1 = pattern.triangle.at(0,0)
    p2 = pattern.triangle.reflect(:r, p1)
    assert_equal Edge.new(p1, p2), data[:edges].keys.first
  end
end

