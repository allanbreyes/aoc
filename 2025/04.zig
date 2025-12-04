const std = @import("std");
const example = @embedFile("examples/04.txt");
const input = @embedFile("inputs/04.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const grid = try parse(data, allocator);

    const result = try findall(grid, allocator);
    return result.len;
}

pub fn part2(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const grid = try parse(data, allocator);

    var removed: u64 = 0;
    var result = try findall(grid, allocator);
    while (result.len > 0) {
        for (result) |coord| {
            grid[coord[0]][coord[1]] = '.';
            removed += 1;
        }
        result = try findall(grid, allocator);
    }
    return removed;
}

pub fn findall(grid: []const []u8, allocator: std.mem.Allocator) ![]const [2]usize {
    var coords = try std.ArrayList([2]usize).initCapacity(allocator, 0);

    for (1..grid.len - 1) |i| {
        for (1..grid[i].len - 1) |j| {
            if (grid[i][j] != '@') continue;
            if (neighbors(grid, i, j) < 4) {
                try coords.append(allocator, [2]usize{ i, j });
            }
        }
    }

    return coords.toOwnedSlice(allocator);
}

fn neighbors(grid: []const []u8, i: usize, j: usize) u8 {
    const adjacent = [8]u8{
        grid[i - 1][j - 1],
        grid[i - 1][j],
        grid[i - 1][j + 1],
        grid[i][j + 1],
        grid[i + 1][j + 1],
        grid[i + 1][j],
        grid[i + 1][j - 1],
        grid[i][j - 1],
    };

    var num: u8 = 0;
    for (adjacent) |n| {
        if (n == '@') num += 1;
    }
    return num;
}

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]const []u8 {
    var lines = std.mem.splitScalar(u8, data, '\n');

    var cols: usize = 0;
    while (lines.next()) |ln| {
        if (ln.len != 0) {
            cols = ln.len;
            break;
        }
    }
    lines.reset();

    var rows: usize = 0;
    while (lines.next()) |ln| {
        if (ln.len != 0) rows += 1;
    }
    lines.reset();

    var grid = try std.ArrayList([]u8).initCapacity(allocator, rows + 2);

    const top = try allocator.alloc(u8, cols + 2);
    @memset(top, '.');
    try grid.append(allocator, top);

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var row = try allocator.alloc(u8, cols + 2);
        row[0] = '.';
        std.mem.copyForwards(u8, row[1 .. 1 + cols], line);
        row[cols + 1] = '.';
        try grid.append(allocator, row);
    }

    const bottom = try allocator.alloc(u8, cols + 2);
    @memset(bottom, '.');
    try grid.append(allocator, bottom);

    return grid.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(13, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(43, result);
}
