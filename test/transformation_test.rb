require 'test/unit'
require 'kaleidoscope/transformation'
require 'kaleidoscope/point'

class TransformationTest < Test::Unit::TestCase
  include Kaleidoscope

  def setup
    @trans = Transformation.new
    @point = Point.new(4, 5)
  end

  def test_default_should_be_identity
    p2 = @trans.apply(@point)
    assert_equal p2, @point
  end

  def test_translate_should_prepare_translation_operation
    @trans.translate(3, -2)
    expected = Point.new(7, 3)
    assert_equal expected, @trans.apply(@point)
  end

  def test_rotation_should_prepare_rotation_operation
    @trans.rotate(Math::PI/6)
    expected = Point.new(0.964, 6.33)
    assert_equal expected, @trans.apply(@point)
  end

  def test_transformations_are_accumulative
    @trans.rotate(Math::PI/6)
    @trans.translate(3, -2)
    expected = Point.new(3.964, 4.33)
    assert_equal expected, @trans.apply(@point)
  end
end
