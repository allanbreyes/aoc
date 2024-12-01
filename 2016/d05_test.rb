# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd05'

class TestD05 < Minitest::Test
  def setup
    @example = 'abc'
  end

  def test_part1
    skip 'slow test' unless ENV['SLOW'] == '05'

    assert_equal '18f47a30', D05.new(@example).part1
  end

  def test_part2
    skip 'slow test' unless ENV['SLOW'] == '05'

    assert_equal '05ace8e3', D05.new(@example).part2
  end
end
