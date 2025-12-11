const std = @import("std");
const example = @embedFile("examples/11.txt");
const example2 = @embedFile("examples/11.2.txt");
const input = @embedFile("inputs/11.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("part1: {d}\n", .{try part1(input, allocator)});
    std.debug.print("part2: {d}\n", .{try part2(input, allocator)});
}

pub fn part1(data: []const u8, allocator: std.mem.Allocator) !u64 {
    const nodes = try parse(data, allocator);
    var cache = Cache.init(allocator);

    return try dfs("you", nodes, true, true, &cache, allocator);
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) !u64 {
    const nodes = try parse(data, allocator);
    var cache = Cache.init(allocator);

    return try dfs("svr", nodes, false, false, &cache, allocator);
}

const Label = []const u8;
const NodeMap = std.StringHashMap(std.ArrayList(Label));
const Cache = std.StringHashMap(u64);

fn dfs(node: Label, nodes: NodeMap, dac: bool, fft: bool, cache: *Cache, allocator: std.mem.Allocator) !u64 {
    if (std.mem.eql(u8, node, "out")) {
        return if (dac and fft) 1 else 0;
    }

    const key = try std.fmt.allocPrint(allocator, "{s}-{any}-{any}", .{ node, dac, fft });
    if (cache.get(key)) |res| return res;

    var result: u64 = 0;
    if (nodes.get(node)) |outputs| {
        for (outputs.items) |output| {
            const new_dac = dac or std.mem.eql(u8, output, "dac");
            const new_fft = fft or std.mem.eql(u8, output, "fft");
            result += try dfs(output, nodes, new_dac, new_fft, cache, allocator);
        }
    }

    try cache.put(key, result);
    return result;
}

fn parse(data: []const u8, allocator: std.mem.Allocator) !NodeMap {
    var nodes = NodeMap.init(allocator);
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        var parts = std.mem.splitScalar(u8, trimmed, ':');
        const label: Label = parts.next().?;
        var outputs = try std.ArrayList(Label).initCapacity(allocator, 0);

        var tokens = std.mem.tokenizeScalar(u8, parts.next().?, ' ');
        while (tokens.next()) |output| {
            if (output.len == 0) continue;
            try outputs.append(allocator, output);
        }

        try nodes.put(label, outputs);
    }
    return nodes;
}

test "part1" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try part1(example, allocator);
    try std.testing.expectEqual(5, result);
}

test "part2" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try part2(example2, allocator);
    try std.testing.expectEqual(2, result);
}
