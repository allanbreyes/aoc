# frozen_string_literal: true

class D20
  def initialize(input, max = 4_294_967_295)
    @input = input
    @max = max
  end

  def part1
    allowed_ips.first
  end

  def part2
    allowed_ips.length
  end

  def allowed_ips
    blocklists = condense(parse)
    prefix = (0...blocklists[0][0]).to_a
    suffix = ((blocklists[-1][1] + 1)..@max).to_a
    middle = blocklists.each_cons(2).map do |a, b|
      low = a[1] + 1
      high = b[0] - 1
      (low..high).to_a
    end.flatten
    prefix + middle + suffix
  end

  def condense(ranges)
    ranges.each_with_object([]) do |range, condensed|
      if condensed.empty?
        condensed << range
      else
        last = condensed[-1]
        if range[0] <= last[1] + 1
          last[1] = [last[1], range[1]].max
        else
          condensed << range
        end
      end
    end
  end

  def parse
    @input.strip.split("\n").map do |line|
      line.split('-').map(&:to_i)
    end.sort
  end
end
