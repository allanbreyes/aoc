# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd07'

class TestD07 < Minitest::Test
  def setup; end

  def test_part1
    example = <<~EXAMPLE
      abba[mnop]qrst
      abcd[bddb]xyyx
      aaaa[qwer]tyui
      ioxxoj[asdfgh]zxcvbn
    EXAMPLE
    assert_equal 2, D07.new(example).part1
  end

  def test_part2
    example = <<~EXAMPLE
      aba[bab]xyz
      xyx[xyx]xyx
      aaa[kek]eke
      zazbz[bzb]cdb
    EXAMPLE
    assert_equal 3, D07.new(example).part2
  end
end
