# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd01'

class TestD01 < Minitest::Test
  def test_part1
    assert_equal 5, D01.new('R2, L3').part1
    assert_equal 2, D01.new('R2, R2, R2').part1
    assert_equal 12, D01.new('R5, L5, R5, R3').part1
  end

  def test_part2
    assert_equal 4, D01.new('R8, R4, R4, R8').part2
  end
end
