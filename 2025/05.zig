const std = @import("std");
const example = @embedFile("examples/05.txt");
const input = @embedFile("inputs/05.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try parse(data, allocator);

    var total: u64 = 0;

    // Should use binary search, but the inputs are small
    for (result.ids) |id| {
        for (result.ranges) |range| {
            if (id >= range[0] and id <= range[1]) {
                total += 1;
                break;
            }
        }
    }

    return total;
}

pub fn part2(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const result = try parse(data, allocator);

    var total: u64 = 0;

    for (result.ranges) |range| {
        total += range[1] - range[0] + 1;
    }

    return total;
}

const ParseResult = struct {
    ranges: []const [2]u64,
    ids: []const u64,
};

fn parse(data: []const u8, allocator: std.mem.Allocator) !ParseResult {
    var ranges = std.ArrayListUnmanaged([2]u64){};
    var ids = std.ArrayListUnmanaged(u64){};

    const trimmed = std.mem.trim(u8, data, " \r\n\t");
    var stanzas = std.mem.splitSequence(u8, trimmed, "\n\n");

    var lines = std.mem.splitScalar(u8, stanzas.next() orelse "", '\n');
    while (lines.next()) |line| {
        const l = std.mem.trim(u8, line, " \r\n\t");
        if (l.len == 0) continue;

        var parts = std.mem.splitScalar(u8, l, '-');
        const start_str = parts.next() orelse continue;
        const stop_str = parts.next() orelse continue;

        const start = try std.fmt.parseInt(u64, std.mem.trim(u8, start_str, " \r\n\t"), 10);
        const stop = try std.fmt.parseInt(u64, std.mem.trim(u8, stop_str, " \r\n\t"), 10);
        try ranges.append(allocator, .{ start, stop });
    }

    const items = ranges.items;
    const Cmp = struct {
        fn lessThan(_: void, a: [2]u64, b: [2]u64) bool {
            return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]);
        }
    };
    std.mem.sort([2]u64, items, {}, Cmp.lessThan);

    var merged = std.ArrayListUnmanaged([2]u64){};
    if (items.len != 0) {
        try merged.append(allocator, items[0]);
        var k: usize = 1;
        while (k < items.len) : (k += 1) {
            const current = items[k];
            const last_index = merged.items.len - 1;
            if (merged.items[last_index][1] >= current[0]) {
                if (current[1] > merged.items[last_index][1]) {
                    merged.items[last_index][1] = current[1];
                }
            } else {
                try merged.append(allocator, current);
            }
        }
    }

    lines = std.mem.splitScalar(u8, stanzas.next() orelse "", '\n');
    while (lines.next()) |line| {
        const l = std.mem.trim(u8, line, " \r\n\t");
        if (l.len == 0) continue;
        const id = try std.fmt.parseInt(u64, l, 10);
        try ids.append(allocator, id);
    }

    return ParseResult{
        .ranges = try merged.toOwnedSlice(allocator),
        .ids = try ids.toOwnedSlice(allocator),
    };
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(3, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(14, result);
}
