# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd14'

class TestD14 < Minitest::Test
  def setup
    @example = 'abc'
  end

  def test_part1
    skip 'slow test' unless ENV['SLOW'] == '14'

    assert_equal 22_728, D14.new(@example).part1
  end

  def test_part2
    skip 'slow test' unless ENV['SLOW'] == '14'

    assert_equal 22_551, D14.new(@example).part2
  end
end
