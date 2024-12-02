# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd18'

class TestD18 < Minitest::Test
  def setup
    @example1 = '..^^.'
    @example2 = '.^^.^.^^^^'
  end

  def test_part1
    assert_equal 6, D18.new(@example1, 3).part1
    assert_equal 38, D18.new(@example2, 10).part1
  end
end
