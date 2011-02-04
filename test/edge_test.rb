require 'test/unit'
require 'kaleidoscope/edge'
require 'kaleidoscope/point'

class EdgeTest < Test::Unit::TestCase
  include Kaleidoscope

  def test_edges_should_have_two_endpoints
    p1, p2 = Point.new(0, 1), Point.new(4, 3)
    edge = Edge.new(p1, p2)
    assert_equal edge.p1, p1
    assert_equal edge.p2, p2
  end

  def test_edges_should_be_equal_if_they_have_endpoints_at_the_same_locations
    p1, p2, p3, p4 = Point.new(0, 1), Point.new(2, 3), Point.new(3, 2), Point.new(0, 1)
    e1 = Edge.new(p1, p2)
    e2 = Edge.new(p1, p3)
    e3 = Edge.new(p4, p2)

    assert_equal e1, e1, "identity should be true"
    assert_not_equal e1, e2
    assert_equal e1, e3
  end

  def test_equivalence_should_work_regardless_of_point_order
    p1, p2 = Point.new(0, 1), Point.new(2, 3)
    e1 = Edge.new(p1, p2)
    e2 = Edge.new(p2, p1)

    assert_equal e1, e2
  end

  def test_edges_should_be_hashable
    p1, p2, p3 = Point.new(0, 1), Point.new(4, 3), Point.new(5, 7)
    e1 = Edge.new(p1, p2)
    e2 = Edge.new(p2, p3)
    e3 = Edge.new(p1, p2)
    e4 = Edge.new(p2, p1)

    h = { e1 => true }
    assert h.key?(e1)
    assert !h.key?(e2)
    assert h.key?(e3)
    assert h.key?(e4)
  end

  def test_length_should_be_the_distance_between_the_endpoints
    p1, p2 = Point.new(1, 2), Point.new(5, 4)
    edge = Edge.new(p1, p2)
    assert_equal Math.sqrt((p2.x - p1.x)**2 + (p2.y - p1.y)**2), edge.length
  end

  def test_edges_are_inside_by_default
    p1, p2 = Point.new(1, 2), Point.new(5, 4)
    edge = Edge.new(p1, p2)
    assert edge.inside?
  end

  def test_asserting_that_an_edge_is_outside_should_make_inside_false
    p1, p2 = Point.new(1, 2), Point.new(5, 4)
    edge = Edge.new(p1, p2)
    edge.outside!
    assert !edge.inside?
  end
end
