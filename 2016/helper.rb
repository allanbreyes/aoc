# frozen_string_literal: true

class PriorityQueue
  def initialize
    @queue = []
  end

  def add(priority, item)
    @queue << [priority, item]
    @queue.sort!
  end

  def pop
    @queue.shift[1]
  end

  def empty?
    @queue.empty?
  end
end
