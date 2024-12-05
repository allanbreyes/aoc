# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd24'

class TestD24 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      ###########
      #0.1.....2#
      #.#######.#
      #4.......3#
      ###########
    EXAMPLE
  end

  def test_part1
    assert_equal 14, D24.new(@example).part1
  end

  def test_part2
    assert_equal 20, D24.new(@example).part2
  end
end
