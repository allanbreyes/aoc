# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd12'

class TestD12 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      cpy 41 a
      inc a
      inc a
      dec a
      jnz a 2
      dec a
    EXAMPLE
  end

  def test_part1
    assert_equal 42, D12.new(@example).part1
  end

  def test_part2
    assert_equal 42, D12.new(@example).part2
  end
end
