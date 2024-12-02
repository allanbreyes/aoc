# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd11'

class TestD11 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
      The second floor contains a hydrogen generator.
      The third floor contains a lithium generator.
      The fourth floor contains nothing relevant.
    EXAMPLE
  end

  def test_part1
    assert_equal 11, D11.new(@example).part1
  end

  def test_part2
    assert_nil D11.new(@example).part2
  end
end
