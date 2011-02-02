require 'test/unit'
require 'kaleidoscope/point'

class PointTest < Test::Unit::TestCase
  def setup
    @point = Kaleidoscope::Point.new(5.5, 6.3)
  end

  def test_constructor_should_set_coordinates
    assert_in_delta 5.5, @point.x, 0.0001
    assert_in_delta 6.3, @point.y, 0.0001
  end
end
