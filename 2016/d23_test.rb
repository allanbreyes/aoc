# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd23'

class TestD23 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      cpy 2 a
      tgl a
      tgl a
      tgl a
      cpy 1 a
      dec a
      dec a
    EXAMPLE
  end

  def test_part1
    assert_equal 3, D23.new(@example).part1
  end

  def test_part2
    assert_equal 3, D23.new(@example).part2
  end
end
