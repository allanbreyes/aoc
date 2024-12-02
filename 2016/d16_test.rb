# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd16'

class TestD16 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      10000
    EXAMPLE
    @solver = D16.new(@example)
  end

  def test_checksum
    assert_equal '100', @solver.checksum('110010110100')
  end

  def test_expand
    assert_equal '100', @solver.expand('1')
    assert_equal '001', @solver.expand('0')
    assert_equal '11111000000', @solver.expand('11111')
    assert_equal '1111000010100101011110000', @solver.expand('111100001010')
  end

  def test_part1
    solver = D16.new(@example)
    solver.size = 20

    assert_equal '01100', solver.part1
  end
end
