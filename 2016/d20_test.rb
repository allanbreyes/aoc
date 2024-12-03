# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd20'

class TestD20 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      5-8
      0-2
      4-7
    EXAMPLE
  end

  def test_part1
    assert_equal 3, D20.new(@example, 9).part1
  end

  def test_part2
    assert_equal 2, D20.new(@example, 9).part2
  end
end
