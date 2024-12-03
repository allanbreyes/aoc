# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd19'

class TestD19 < Minitest::Test
  def setup
    @example = '5'
  end

  def test_part1
    assert_equal 3, D19.new(@example).part1
  end

  def test_part2
    assert_equal 2, D19.new(@example).part2
  end
end
