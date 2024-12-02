# frozen_string_literal: true

class D09
  def initialize(input)
    @input = input
  end

  def part1
    decompress(str: parse, recurse: false)
  end

  def part2
    decompress(str: parse, recurse: true)
  end

  def decompress(str:, recurse: false)
    i = 0
    length = 0

    while i < str.length
      if str[i] == '('
        i += 1
        close = str[i..].index(')') + i
        chars, repeat = str[i...close].split('x').map(&:to_i)
        i = close

        sublength = recurse ? decompress(str: str[(i + 1)...(i + chars + 1)], recurse: true) : chars
        i += chars
        length += repeat * sublength
      else
        length += 1
      end

      i += 1
    end

    length
  end

  def parse
    @input.strip.gsub(/\s/, '')
  end
end
