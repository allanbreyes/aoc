# frozen_string_literal: true

require 'pry'

class Item
  attr_reader :element, :type

  def initialize(element, type)
    @element = element
    @type = type
  end

  def generator?
    type == :generator
  end

  def microchip?
    type == :microchip
  end

  def to_s
    "#{element[..1].upcase}#{type[0].upcase}"
  end
end

class State
  attr_reader :floors, :elevator, :steps

  def initialize(floors, elevator = 0, steps = 0)
    @floors = floors
    @elevator = elevator
    @steps = steps
  end

  def display!
    puts "\n============================ #{@steps} ============================"
    @floors.reverse.each.with_index do |floor, i|
      j = @floors.size - i
      puts "F#{j} #{@elevator == j - 1 ? 'E' : ' '} #{floor.map(&:to_s).join(' ')}"
    end
  end

  def key
    positions = @floors.map.with_index do |items, floor|
      items.map { |item| [floor, item] }
    end.flatten(1)
    positions.group_by { |_, item| item.element }.values.map do |pair|
      pair.map(&:first)
    end.sort + [@elevator]
  end

  def next_states
    floor = @floors[@elevator]
    stops = [-1, +1].map { |offset| @elevator + offset }
                    .select { |stop| stop.between? 0, @floors.length - 1 }
    stops.flat_map do |stop|
      (1..2).flat_map do |n|
        floor.combination(n).map do |items|
          peek(stop, items)
        end
      end
    end.compact.select(&:safe?)
  end

  def peek(stop, items)
    State.new(@floors.dup.tap do |floors|
      raise 'Floor does not contain items' unless items.all? { |item| floors[@elevator].include?(item) }

      floors[@elevator] -= items
      floors[stop] += items
    end, stop, @steps + 1)
  end

  def safe?
    @floors.all? do |floor|
      generators, microchips = floor.partition(&:generator?)
      generators.empty? || microchips.all? do |microchip|
        generators.any? { |generator| generator.element == microchip.element }
      end
    end
  end

  def solved?
    @floors[...-1].all?(&:empty?)
  end
end

class D11
  def initialize(input)
    @input = input
  end

  def part1
    state = solve!(State.new(parse))
    state.steps
  end

  def part2
    floors = parse
    %w[elerium dilithium].each do |element|
      %w[generator microchip].each do |type|
        floors[0] << Item.new(element, type.to_sym)
      end
    end
    State.new(floors)
    state = solve!(State.new(floors))
    return if state.nil?

    state.steps
  end

  def solve!(state)
    queue = [state]
    visited = Set[state.key]

    loop do
      queue.shift.next_states.each do |next_state|
        return next_state if next_state.solved?
        next unless visited.add?(next_state.key)

        queue << next_state
      end
      break if queue.empty?
    end
    nil
  end

  def parse
    @input.strip.split("\n").map.with_index do |line, _i|
      floor = line.scan(/ a (\w+)(?:-compatible)? (\w+)/).map do |element, type|
        raise "Invalid element: #{element}" unless %w[generator microchip].include?(type)

        Item.new(element, type.to_sym)
      end
      floor.sort_by(&:element)
    end
  end
end
