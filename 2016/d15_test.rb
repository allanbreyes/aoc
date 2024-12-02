# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd15'

class TestD15 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      Disc #1 has 5 positions; at time=0, it is at position 4.
      Disc #2 has 2 positions; at time=0, it is at position 1.
    EXAMPLE
  end

  def test_part1
    assert_equal 5, D15.new(@example).part1
  end

  def test_part2
    assert_equal 85, D15.new(@example).part2
  end
end
