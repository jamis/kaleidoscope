require 'test/unit'
require 'kaleidoscope/triangle'
require 'kaleidoscope/point'

class TriangleTest < Test::Unit::TestCase
  include Kaleidoscope

  def setup
    @triangle = Triangle.new(6, 3)
  end

  def test_constructor_sets_schwarzian_parameters
    assert_equal 6, @triangle.p
    assert_equal 3, @triangle.q
  end

  def test_length_of_sides_should_be_computed_using_p_and_q
    assert_in_delta 0.5, @triangle.p_length, 0.001
    assert_in_delta 0.866, @triangle.q_length, 0.001
  end

  def test_convert_barycentric_coordinates_to_cartesian
    point = @triangle.at(0.5, 0.4)
    expected = Point.new(0.5 * 0.866, 0.4 * 0.5)
    assert_equal point, expected
  end

  def test_reflect_across_q_should_just_reverse_sign_of_y
    point = @triangle.reflect(:q, Point.new(0.5, 0.4))
    expected = Point.new(0.5, -0.4)
    assert_equal point, expected
  end

  def test_reflect_across_p_should_just_reverse_sign_of_x
    point = @triangle.reflect(:p, Point.new(0.5, 0.4))
    expected = Point.new(-0.5, 0.4)
    assert_equal point, expected
  end

  def test_reflect_origin_across_r_should_mirror_coordinates_across_hypotenuse
    point = @triangle.reflect(:r, Point.new(0, 0))
    expected = Point.new(0.433, 0.75)
    assert_equal point, expected
  end

  def test_reflect_interior_point_across_r_should_mirror_coordinates_across_hypotenuse
    point = @triangle.reflect(:r, Point.new(0.1, 0.2))
    expected = Point.new(0.3098, 0.5634)
    assert_equal point, expected
  end

  def test_angle_at_should_return_angle_at_the_given_vertex
    assert_equal Math::PI/6, @triangle.angle_at(:p)
    assert_equal Math::PI/3, @triangle.angle_at(:q)
    assert_equal Math::PI/2, @triangle.angle_at(:r)
  end

  def test_incenter_should_return_uv_coordinates_of_the_incenter
    circ = @triangle.q_length + @triangle.p_length + 1
    u = @triangle.p_length / circ
    v = @triangle.q_length / circ

    assert_equal [u, v], @triangle.incenter

    tri = Triangle.new(4, 4)
    circ = tri.q_length + tri.p_length + 1
    u = tri.p_length / circ
    v = tri.q_length / circ

    assert_equal [u, v], tri.incenter
  end

  def test_value_should_return_named_parameter
    assert_equal 6, @triangle.value(:p)
    assert_equal 3, @triangle.value(:q)
    assert_equal 2, @triangle.value(:r)
  end

  def test_triangles_with_the_same_parameters_should_be_equal
    tri2 = Triangle.new(@triangle.p, @triangle.q)
    assert_equal tri2, @triangle
  end
end
