# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd08'

class TestD08 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      rect 3x2
      rotate column x=1 by 1
      rotate row y=0 by 4
      rotate column x=1 by 1
    EXAMPLE
  end

  def test_part1
    assert_equal 6, D08.new(@example).part1
  end
end
