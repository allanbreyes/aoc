# frozen_string_literal: true

class D21
  def initialize(input, seed = 'abcdefgh', scrambled = 'fbgdceah')
    @input = input
    @seed = seed
    @scrambled = scrambled
  end

  def part1
    parse.reduce(@seed) do |acc, (op, *args)|
      send(op, acc, *args)
    end
  end

  def part2
    parse.reverse.reduce(@scrambled) do |acc, (op, *args)|
      op, args = case op
                 when :swap_position, :swap_letter, :reverse_positions then [op, args]
                 when :rotate then [:rotate, args.map(&:-@)]
                 when :rotate_on_letter then [:undo_rotate_on_letter, args]
                 when :move then [:move, args.reverse]
                 else
                   raise "Unknown operation: #{op} #{args}"
                 end
      send(op, acc, *args)
    end
  end

  private

  def swap_position(string, x, y)
    # swap position X with position Y means that the letters at indexes X and Y
    # (counting from 0) should be swapped.
    string.dup.tap { |s| s[x], s[y] = s[y], s[x] }
  end

  def swap_letter(string, x, y)
    # swap letter X with letter Y means that the letters X and Y should be
    # swapped (regardless of where they appear in the string).
    string.dup.tap do |s|
      s.tr!(x + y, y + x)
    end
  end

  def rotate(string, offset)
    # rotate left/right X steps means that the whole string should be rotated;
    # for example, one right rotation would turn abcd into dabc.
    string.chars.rotate!(-offset).join
  end

  def rotate_on_letter(string, x)
    # rotate based on position of letter X means that the whole string should be
    # rotated to the right based on the index of letter X (counting from 0) as
    # determined before this instruction does any rotations. Once the index is
    # determined, rotate the string to the right one time, plus a number of
    # times equal to that index, plus one additional time if the index was at
    # least 4.
    i = string.index(x)
    i += 1 if i >= 4
    i += 1
    rotate(string, i)
  end

  def undo_rotate_on_letter(string, x)
    # HACK: brute-force to find the original string
    string.chars.tap do |c|
      c.rotate!(1) until rotate_on_letter(c.join, x) == string
    end.join
  end

  def reverse_positions(string, x, y)
    # reverse positions X through Y means that the span of letters at indexes X
    # through Y (including the letters at X and Y) should be reversed in order.
    string.dup.tap do |s|
      s[x..y] = s[x..y].reverse
    end
  end

  def move(string, x, y)
    # move position X to position Y means that the letter which is at index X
    # should be removed from the string, then inserted such that it ends up at
    # index Y.
    s = string.dup
    s.insert(y, s.slice!(x))
  end

  def parse
    @input.strip.split("\n").map do |line|
      case line
      when /swap position (\d+) with position (\d+)/
        [:swap_position, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i]
      when /swap letter (\w) with letter (\w)/
        [:swap_letter, ::Regexp.last_match(1), ::Regexp.last_match(2)]
      when /rotate (left|right) (\d+) steps?/
        [:rotate, ::Regexp.last_match(2).to_i * (::Regexp.last_match(1) == 'left' ? -1 : 1)]
      when /rotate based on position of letter (\w)/
        [:rotate_on_letter, ::Regexp.last_match(1)]
      when /reverse positions (\d+) through (\d+)/
        [:reverse_positions, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i]
      when /move position (\d+) to position (\d+)/
        [:move, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i]
      end
    end
  end
end
