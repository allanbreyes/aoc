# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd04'

class TestD04 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      aaaaa-bbb-z-y-x-123[abxyz]
      a-b-c-d-e-f-g-h-987[abcde]
      not-a-real-room-404[oarel]
      totally-real-room-200[decoy]
      qzmt-zixmtkozy-ivhz-343[crypt]
      ijmockjgz-jwezxo-nojmvbz-993[north]
    EXAMPLE
  end

  def test_part1
    assert_equal 1514, D04.new(@example).part1
  end

  def test_part2
    assert_equal 993, D04.new(@example).part2
  end
end
