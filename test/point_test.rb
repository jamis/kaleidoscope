require 'test/unit'
require 'kaleidoscope/point'

class PointTest < Test::Unit::TestCase
  include Kaleidoscope

  def setup
    @point = Point.new(5.5, 6.3)
  end

  def test_constructor_should_set_coordinates
    assert_in_delta 5.5, @point.x, 0.0001
    assert_in_delta 6.3, @point.y, 0.0001
  end

  def test_comparison_should_work_within_some_delta
    p2 = Point.new(5.6, 6.3)
    assert_not_equal @point, p2

    p2 = Point.new(5.5, 6.4)
    assert_not_equal @point, p2

    p2 = Point.new(5.5001, 6.3001)
    assert_equal @point, p2
  end

  def test_points_should_be_hashable
    p2 = Point.new(5.5, 6.3)
    p3 = Point.new(5.5, 6.4)

    h = { @point => true }
    assert h.key?(@point)
    assert h.key?(p2)
    assert !h.key?(p3)
  end

  def test_translate_should_create_new_point_offset_by_the_given_amounts
    p2 = @point.translate(1.2, -3.7)
    expected = Point.new(6.7, 2.6)
    assert_not_equal p2, @point
    assert_equal p2, expected
  end
end
