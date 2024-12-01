# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd00'

class TestD00 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      foo
      bar
      baz
    EXAMPLE
  end

  def test_part1
    assert_equal 3, D00.new(@example).part1
  end

  def test_part2
    assert_equal 3, D00.new(@example).part2
  end
end
