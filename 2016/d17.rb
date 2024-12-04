# frozen_string_literal: true

require 'digest/md5'
require_relative 'helper'

class D17
  def initialize(input)
    @passcode = input.strip
    @dim = 4
    @start = [0, 0]
    @goal = [@dim - 1, @dim - 1]

    # Memoize openings
    @openings = {}
  end

  def part1
    seek { |path| return path }
  end

  def part2
    longest = ''
    seek do |path|
      longest = [longest, path].max_by(&:length)
    end
    longest.length
  end

  def seek
    queue = PriorityQueue.new
    queue.add(1, [@start, '', 0])

    until queue.empty?
      pos, path, steps = queue.pop

      if pos == @goal
        yield path
        next
      end

      neighbors(pos, path).each do |nx, ny, dir|
        queue.add(steps + 1, [[nx, ny], "#{path}#{dir}", steps + 1])
      end
    end
  end

  def neighbors(pos, path)
    x, y = pos
    moves = openings(path).map do |dir|
      case dir
      when :U then [x, y - 1]
      when :D then [x, y + 1]
      when :L then [x - 1, y]
      when :R then [x + 1, y]
      end + [dir]
    end
    moves.select do |nx, ny, _|
      nx.between?(0, @dim - 1) && ny.between?(0, @dim - 1)
    end
  end

  def openings(path = '')
    @openings[path] ||= begin
      digest = Digest::MD5.hexdigest(@passcode + path).chars[0..3]
      digest.map.with_index do |c, i|
        next unless c.to_i(16) > 10

        { 0 => :U, 1 => :D, 2 => :L, 3 => :R }[i]
      end.compact
    end
    @openings[path]
  end
end
