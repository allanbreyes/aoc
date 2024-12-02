# frozen_string_literal: true

class D08
  def initialize(input)
    @input = input
  end

  def part1
    @screen = Array.new(6) { Array.new(50, 0) }
    parse.each do |method, *args|
      send(method, *args)
    end
    @screen.flatten.count(1)
  end

  def part2
    display
  end

  def display
    # rubocop:disable Style/StringConcatenation
    "\n" + @screen.map do |row|
      row.map { |cell| cell == 1 ? '#' : '.' }.join
    end.join("\n")
  end

  def rect!(x, y)
    y.times do |i|
      x.times do |j|
        @screen[i][j] = 1
      end
    end
  end

  def rotate_row!(row, n)
    @screen[row].rotate!(-n)
  end

  def rotate_col!(col, n)
    transposed = @screen.transpose
    transposed[col].rotate!(-n)
    @screen = transposed.transpose
  end

  # rubocop:disable Metrics/MethodLength
  def parse
    @input.strip.split("\n").map do |line|
      case line
      when /^rect (\d+)x(\d+)$/
        [:rect!, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i]
      when /^rotate row y=(\d+) by (\d+)$/
        [:rotate_row!, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i]
      when /^rotate column x=(\d+) by (\d+)$/
        [:rotate_col!, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i]
      else
        raise "Invalid input: #{line}"
      end
    end
  end
end
