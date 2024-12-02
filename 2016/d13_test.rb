# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd13'

class TestD13 < Minitest::Test
  def setup
    @example = '10'
    @target = [7, 4]
  end

  def test_part1
    assert_equal 11, D13.new(@example, @target).part1
  end

  def test_part2
    skip 'slow test' unless ENV['SLOW'] == '13'

    assert_equal 151, D13.new(@example, @target).part2
  end
end
