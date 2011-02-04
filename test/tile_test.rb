require 'test/unit'
require 'kaleidoscope/tile'
require 'kaleidoscope/triangle'

class TileTest < Test::Unit::TestCase
  include Kaleidoscope

  def test_tile_should_be_defined_by_p_q_u_v
    tile = Tile.new(6, 3, 0.3, 0.5)
    assert_equal tile.triangle, Triangle.new(6, 3)
    assert_equal 0.3, tile.u
    assert_equal 0.5, tile.v
  end

  def test_tile_should_default_uv_to_incenter
    tile = Tile.new(6, 3)
    u, v = tile.triangle.incenter
    assert_equal u, tile.u
    assert_equal v, tile.v
  end

  def test_tile_should_generate_edges
    [Tile.new(6, 3), Tile.new(4, 4), Tile.new(3, 6), Tile.new(2.4, 12)].each do |tile|
      tile = Tile.new(6, 3)

      points, edges = expected_data_for(tile)
      assert_equal tile.edges.length, edges.length

      assert edges.all? { |e| tile.edges.include?(e) }
    end
  end

  def test_tile_should_omit_degenerate_edges
    tile = Tile.new(3, 6, 0, 1)
    assert_equal 1, tile.edges.length
    assert_equal 2, tile.polygons.length
  end

  def test_tile_should_group_edges_by_polygon_centerpoint
    tile = Tile.new(6, 3)
    assert_equal 5, tile.polygons.length

    c = Point.new(0,0)
    p1 = tile.triangle.at(1,0)
    p2 = tile.triangle.at(0,1)
    p3 = tile.triangle.at(-1,0)
    p4 = tile.triangle.at(0,-1)

    assert_equal 4, tile.polygons[c].length
    assert_equal 3, tile.polygons[p1].length
    assert_equal 3, tile.polygons[p2].length
    assert_equal 3, tile.polygons[p3].length
    assert_equal 3, tile.polygons[p4].length
  end

  def test_polygon_edges_should_map_to_centerpoint_of_neighboring_polygon
    tile = Tile.new(6, 3)

    c1 = Point.new(0,0)
    c2 = tile.triangle.at(1, 0)

    p1 = tile.triangle.at(tile.u, tile.v)
    p2 = Point.new(p1.x, -p1.y)
    edge = Edge.new(p1, p2)

    assert_equal c2, tile.polygons[c1][edge]
  end

  def test_phase_angle_should_be_twice_p_theta
    tile = Tile.new(6, 3)
    assert_equal tile.phase_angle, tile.triangle.p_theta*2

    tile = Tile.new(4, 4)
    assert_equal tile.phase_angle, tile.triangle.p_theta*2

    tile = Tile.new(2.4, 12)
    assert_equal tile.phase_angle, tile.triangle.p_theta*2
  end

  def test_phase_count_should_be_p
    tile = Tile.new(6, 3)
    assert_equal 6, tile.phase_count

    tile = Tile.new(4, 4)
    assert_equal 4, tile.phase_count

    tile = Tile.new(12, 2.4)
    assert_equal 12, tile.phase_count
  end

  def test_phase_0_should_return_tile_data_offset_by_minus_q_length
    tile = Tile.new(6, 3)
    data = tile.phase(0)

    points, edges = expected_data_for(tile)
    assert_equal data[:edges].length, edges.length

    edges.each do |edge|
      p1 = edge.p1.translate(-tile.triangle.q_length, 0)
      p2 = edge.p2.translate(-tile.triangle.q_length, 0)
      assert data[:edges].include?(Edge.new(p1, p2))
    end
  end

  def test_phase_1_should_rotate_tile_data_around_p
    tile = Tile.new(6, 3)
    data = tile.phase(1)

    points, edges = expected_data_for(tile)

    t = Transformation.new
    t.translate(-tile.triangle.q_length, 0)
    t.rotate(tile.phase_angle)

    edges.each do |edge|
      e = Edge.new(t.apply(edge.p1), t.apply(edge.p2))
      assert data[:edges].include?(e)
    end
  end

  def test_phase_should_report_neighbor
    tile = Tile.new(6, 3)
    data = tile.phase(0)
    assert_equal Point.new(-1.732, 0), data[:neighbor]
  end

  def test_phase_should_report_polygons
    tile = Tile.new(6, 3)
    data = tile.phase(0)

    assert_equal 5, data[:polygons].length
    tile.polygons.keys.each do |center|
      c2 = center.translate(-tile.triangle.q_length, 0)
      assert data[:polygons][c2].is_a?(Hash)
    end
  end

  private

  def expected_data_for(tile)
    p1 = tile.triangle.at(tile.u, tile.v)
    p2 = Point.new(p1.x, -p1.y)
    p3 = Point.new(-p1.x, -p1.y)
    p4 = Point.new(p1.x, -p1.y)

    p5 = tile.triangle.reflect(:r, p1)
    p6 = Point.new(p5.x, -p5.y)
    p7 = Point.new(-p5.x, -p5.y)
    p8 = Point.new(p5.x, -p5.y)

    e1 = Edge.new(p1, p2)
    e2 = Edge.new(p1, p4)
    e3 = Edge.new(p2, p3)
    e4 = Edge.new(p3, p4)

    e5 = Edge.new(p1, p5)
    e6 = Edge.new(p2, p6)
    e7 = Edge.new(p3, p7)
    e8 = Edge.new(p4, p8)

    [[p1, p2, p3, p4, p5, p6, p7, p8],
     [e1, e2, e3, e4, e5, e6, e7, e8]]
  end
end
