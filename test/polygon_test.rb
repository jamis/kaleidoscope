require 'test/unit'
require 'kaleidoscope/polygon'

class PolygonTest < Test::Unit::TestCase
  include Kaleidoscope

  def test_polygon_initially_has_no_edges
    poly = Polygon.new
    assert poly.edges.empty?
  end

  def test_polygon_is_initially_assumed_to_be_inside
    poly = Polygon.new
    assert poly.inside?
  end

  def test_asserting_the_polygon_is_outside_causes_inside_to_be_false
    poly = Polygon.new
    poly.outside!
    assert !poly.inside?
  end
end
