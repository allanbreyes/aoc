# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd03'

class TestD03 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      101 301 501
      102 302 502
      103 303 503
      201 401 601
      202 402 602
      203 403 603
    EXAMPLE
  end

  def test_part1
    assert_equal 3, D03.new(@example).part1
  end

  def test_part2
    assert_equal 6, D03.new(@example).part2
  end
end
