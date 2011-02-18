require 'test/unit'
require 'kaleidoscope/pattern'
require 'kaleidoscope/point'
require 'kaleidoscope/edge'

class PatternTest < Test::Unit::TestCase
  include Kaleidoscope

  def test_constructor_sets_attributes
    pattern = Pattern.new(6, 3, 0.3, 0.4)
    assert_equal 6, pattern.p
    assert_equal 3, pattern.q
    assert_equal 0.3, pattern.u
    assert_equal 0.4, pattern.v
  end

  def test_constructor_without_explicit_uv_should_compute_incenter
    p1 = Pattern.new(3, 6)
    t1 = Triangle.new(3, 6)
    p2 = Pattern.new(4, 4)
    t2 = Triangle.new(4, 4)

    assert_equal t1.incenter, [p1.u, p1.v]
    assert_equal t2.incenter, [p2.u, p2.v]
  end

  def test_constructor_should_initialize_polygon_and_edge_lists_to_empty
    pattern = Pattern.new(6, 3)
    assert pattern.polygons.empty?
    assert pattern.edges.empty?
  end

  def test_build_at_should_tile_all_phases_at_the_given_point
    pattern = Pattern.new(6, 3)
    pattern.build_at(Point.new(0, 0), 0)
    assert_equal 19, pattern.polygons.length
    assert_equal 42, pattern.edges.length
  end

  def test_build_at_with_even_increment_should_not_rotate_tile_for_odd_p
    origin, pattern = Point.new(0, 0), Pattern.new(3, 6)
    neighbors = pattern.build_at(origin, 0)
    assert neighbors.include?(Point.new(-1, 0))
    assert !neighbors.include?(Point.new(1, 0))
  end

  def test_build_at_with_odd_increment_should_rotate_tile_for_odd_p
    origin, pattern = Point.new(0, 0), Pattern.new(3, 6)
    neighbors = pattern.build_at(origin, 1)
    assert !neighbors.include?(Point.new(-1, 0))
    assert neighbors.include?(Point.new(1, 0))
  end

  def test_generate_should_build_out_polygons_and_edges_within_the_specified_bounds
    p = Pattern.new(6, 3)
    p.generate! { |pt| pt.x.between?(-1.01, 1.01) && pt.y.between?(-1.01, 1.01) }
    assert_equal 17, p.polygons.length
    assert_equal 36, p.edges.length
  end

  def test_generate_should_mark_polygons_as_outside_when_they_are_not_fully_inside_the_bounds
    p = Pattern.new(6, 3)
    p.generate! { |pt| pt.x.between?(-1.01, 1.01) && pt.y.between?(-1.01, 1.01) }
    assert_equal 5, p.polygons.select { |poly| poly.inside? }.length
  end

  def test_generate_should_mark_edges_as_outside_when_they_are_not_fully_inside_the_bounds
    p = Pattern.new(6, 3)
    p.generate! { |pt| pt.x.between?(-1.01, 1.01) && pt.y.between?(-1.01, 1.01) }
    assert_equal 24, p.edges.select { |edge| edge.inside? }.length
  end

  def test_generate_should_cover_all_seed_sites_within_the_bounds
    p = Pattern.new(6, 3)
    p.generate! { |pt| pt.x.between?(-1.01, 3.01) && pt.y.between?(-1.01, 3.01) }
    assert_equal 50, p.polygons.length
  end
end
