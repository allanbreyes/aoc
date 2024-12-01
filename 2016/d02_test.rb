# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd02'

class TestD02 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      ULL
      RRDDD
      LURDL
      UUUUD
    EXAMPLE
  end

  def test_part1
    assert_equal 1985, D02.new(@example).part1
  end

  def test_part2
    assert_equal '5DB3', D02.new(@example).part2
  end
end
