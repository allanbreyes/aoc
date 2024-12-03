# frozen_string_literal: true

class Elf
  attr_accessor :prev, :next, :presents
  attr_reader :number

  def initialize(number, right:, left:)
    @number = number
    @presents = 1
    @prev = right
    @next = left
  end

  def alone?
    @next == self && @prev == self
  end

  def steal!(other = nil)
    other ||= @next
    @presents += other.presents
    other.presents = 0
    other.skip!
  end

  protected

  def skip!
    @next.prev = @prev
    @prev.next = @next
    @next = @prev = nil
  end
end

class Ring
  attr_accessor :size

  def initialize(size)
    first = Elf.new(1, right: nil, left: nil)
    @lookup = { 1 => first }
    @size = size

    last = first
    (2..size).each do |i|
      elf = Elf.new(i, right: last, left: first)
      last.next = elf
      @lookup[i] = last = elf
    end
    # rubocop:disable Lint/UselessSetterCall
    first.prev = last
  end

  def [](number)
    @lookup[number]
  end
end

class D19
  def initialize(input)
    @size = input.to_i
  end

  def part1
    ring = Ring.new(@size)
    elf = ring[1]
    until elf.alone?
      elf.steal!
      elf = elf.next
    end
    elf.number
  end

  def part2
    ring = Ring.new(@size)
    elf = other = ring[1]
    (ring.size / 2).times { other = other.next }

    until elf.alone?
      next_other = ring.size.even? ? other.next : other.next.next
      elf.steal! other
      other = next_other
      ring.size -= 1

      elf = elf.next
    end
    elf.number
  end
end
