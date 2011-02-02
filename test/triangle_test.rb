require 'test/unit'
require 'kaleidoscope/triangle'

class TriangleTest < Test::Unit::TestCase
  def setup
    @triangle = Kaleidoscope::Triangle.new(6, 3)
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
    x, y = @triangle.at(0.5, 0.4)
    assert_in_delta 0.5*0.5, x, 0.001
    assert_in_delta 0.4*0.866, y, 0.001
  end

  def test_reflect_across_p_should_just_reverse_sign_of_x
    x, y = @triangle.reflect(:p, 0.5, 0.4)
    assert_in_delta -0.5, x, 0.001
    assert_in_delta 0.4, y, 0.001
  end

  def test_reflect_across_q_should_just_reverse_sign_of_y
    x, y = @triangle.reflect(:q, 0.5, 0.4)
    assert_in_delta 0.5, x, 0.001
    assert_in_delta -0.4, y, 0.001
  end

  def test_reflect_origin_across_r_should_mirror_coordinates_across_hypotenuse
    x, y = @triangle.reflect(:r, 0, 0)
    assert_in_delta 0.75, x, 0.001
    assert_in_delta 0.433, y, 0.001
  end

  def test_reflect_interior_point_across_r_should_mirror_coordinates_across_hypotenuse
    x, y = @triangle.reflect(:r, 0.1, 0.2)
    assert_in_delta 0.5268, x, 0.0001
    assert_in_delta 0.4464, y, 0.0001
  end
end
