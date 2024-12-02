# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd09'

class TestD09 < Minitest::Test
  def test_part1
    example = 'X(8x2)(3x3)ABCY'

    assert_equal 18, D09.new(example.gsub(/\s/, '').strip).part1
  end

  def test_part2
    example = '(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN'

    assert_equal 445, D09.new(example).part2
  end
end
