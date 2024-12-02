# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd06'

class TestD06 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      eedadn
      drvtee
      eandsr
      raavrd
      atevrs
      tsrnev
      sdttsa
      rasrtv
      nssdts
      ntnada
      svetve
      tesnvt
      vntsnd
      vrdear
      dvrsen
      enarar
    EXAMPLE
  end

  def test_part1
    assert_equal 'easter', D06.new(@example).part1
  end

  def test_part2
    assert_equal 'advent', D06.new(@example).part2
  end
end
