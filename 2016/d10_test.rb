# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd10'

class TestD10 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      value 5 goes to bot 2
      bot 2 gives low to bot 1 and high to bot 0
      value 3 goes to bot 1
      bot 1 gives low to output 1 and high to bot 0
      bot 0 gives low to output 2 and high to output 0
      value 2 goes to bot 2
    EXAMPLE
  end

  def test_part1
    assert_nil D10.new(@example).part1
  end

  def test_part2
    assert_equal 30, D10.new(@example).part2
  end
end
