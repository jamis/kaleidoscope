require 'test/unit'
require 'kaleidoscope/polygon'
require 'kaleidoscope/edge'
require 'kaleidoscope/point'

class PolygonTest < Test::Unit::TestCase
  include Kaleidoscope

  class Master
    def initialize
      @polygons = {}
    end

    def add_polygon(center, poly)
      @polygons[center] = poly
    end

    def polygon_at(point)
      @polygons[point]
    end
  end

  def setup
    @master = Master.new
  end

  def test_polygon_constructor_expects_master_object
    poly = Polygon.new(@master)
    assert_equal @master, poly.master
  end

  def test_polygon_initially_has_no_edges
    poly = Polygon.new(@master)
    assert poly.edges.empty?
  end

  def test_polygon_is_initially_assumed_to_be_inside
    poly = Polygon.new(@master)
    assert poly.inside?
  end

  def test_asserting_the_polygon_is_outside_causes_inside_to_be_false
    poly = Polygon.new(@master)
    poly.outside!
    assert !poly.inside?
  end

  def test_edge_map_should_be_a_mapping_of_edges_to_center_points_of_adjacent_polygons
    poly = Polygon.new(@master)

    edge = Edge.new(Point.new(1,2), Point.new(5,4))
    poly.edge_map[edge] = Point.new(-2,-4)

    assert_equal 1, poly.edges.length
  end

  def test_neighbor_via_should_return_polygon_on_other_side_of_given_edge
    poly1 = Polygon.new(@master)
    poly2 = Polygon.new(@master)

    c1 = Point.new(-2,-4)
    c2 = Point.new(4, 2)

    @master.add_polygon(c1, poly1)
    @master.add_polygon(c2, poly2)

    edge = Edge.new(Point.new(1,2), Point.new(5,4))

    poly1.edge_map[edge] = c2
    poly2.edge_map[edge] = c1

    assert_equal poly2, poly1.neighbor_via(edge)
    assert_equal poly1, poly2.neighbor_via(edge)
  end
end
