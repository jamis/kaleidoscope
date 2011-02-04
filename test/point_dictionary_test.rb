require 'test/unit'
require 'kaleidoscope/point_dictionary'

class PointDictionaryTest < Test::Unit::TestCase
  include Kaleidoscope

  def test_dictionary_requesting_a_point_returns_that_point
    dict = PointDictionary.new
    point = Point.new(3,4)
    canonical = dict.canonical(point)
    assert_equal point, canonical
  end

  def test_requesting_distinct_points_gives_distinct_points
    dict = PointDictionary.new
    p1, p2 = Point.new(3,4), Point.new(8, 9)
    c1, c2 = dict.canonical(p1), dict.canonical(p2)
    assert_equal p1, c1
    assert_equal p2, c2
  end

  def test_requesting_nearby_point_returns_nearest_canonical_point
    dict = PointDictionary.new
    p1, p2 = Point.new(3.1,4.2), Point.new(3.14,4.24)
    c1, c2 = dict.canonical(p1), dict.canonical(p2)
    assert_equal p1, c1
    assert_equal p1, c2

    p1, p2 = Point.new(3.1,4.2), Point.new(3.05,4.15)
    c1, c2 = dict.canonical(p1), dict.canonical(p2)
    assert_equal p1, c1
    assert_equal p1, c2
  end
end
