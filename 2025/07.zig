const std = @import("std");
const example = @embedFile("examples/07.txt");
const input = @embedFile("inputs/07.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const grid = try parse(data, allocator);

    const filled = try fill(grid, allocator);

    if (std.process.getEnvVarOwned(allocator, "SHOW")) |_| {
        try display(filled.grid);
    } else |err| {
        if (err != error.EnvironmentVariableNotFound) return err;
    }

    return filled.count;
}

pub fn part2(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const grid = try parse(data, allocator);
    const start = try find_start(grid);
    var cache = std.AutoHashMap(Pos, u64).init(allocator);
    return try dfs(grid, start, &cache);
}

const Grid = []const []u8;
const Pos = [2]usize;
const FillResult = struct {
    grid: Grid,
    count: u64,
};

fn dfs(grid: Grid, pos: Pos, cache: *std.AutoHashMap(Pos, u64)) !u64 {
    const i = pos[0];
    const j = pos[1];
    if (cache.get(pos)) |value| return value;

    if (i >= grid.len) return 1;
    if (i < 0 or j < 0 or j >= grid[i].len) return error.OutOfBounds;

    const cell = grid[i][j];
    var result: u64 = 0;
    switch (cell) {
        'S', '.' => {
            result += try dfs(grid, .{ i + 1, j }, cache);
        },
        '^' => {
            result += try dfs(grid, .{ i + 1, j - 1 }, cache);
            result += try dfs(grid, .{ i + 1, j + 1 }, cache);
        },
        else => {
            return error.UnhandledCell;
        },
    }
    try cache.put(pos, result);
    return result;
}

fn display(grid: Grid) !void {
    for (grid) |row| {
        for (row) |cell| {
            std.debug.print("{c}", .{cell});
        }
        std.debug.print("\n", .{});
    }
}

fn find_start(grid: Grid) !Pos {
    for (grid, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (cell == 'S') return [2]usize{ i, j };
        }
    }
    return error.StartNotFound;
}

fn fill(grid: Grid, allocator: std.mem.Allocator) !FillResult {
    var out = try allocator.alloc([]u8, grid.len);
    var count: u64 = 0;
    for (grid, 0..) |row, i| {
        var new_row = try allocator.alloc(u8, row.len);
        std.mem.copyForwards(u8, new_row, row);
        for (row, 0..) |cell, j| {
            if (cell != '.') continue;

            if (i > 0 and (out[i - 1][j] == 'S' or out[i - 1][j] == '|')) new_row[j] = '|';
            if (j < row.len - 1 and new_row[j + 1] == '^' and out[i - 1][j + 1] == '|') new_row[j] = '|';
            if (j > 0 and new_row[j - 1] == '^' and out[i - 1][j - 1] == '|') {
                new_row[j] = '|';
                count += 1;
            }
        }
        out[i] = new_row;
    }
    return FillResult{ .grid = out, .count = count };
}

fn parse(data: []const u8, allocator: std.mem.Allocator) !Grid {
    const approx_lines = std.mem.count(u8, data, "\n") + 1;
    var grid = try std.ArrayList([]u8).initCapacity(allocator, approx_lines);
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const row = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, row, line);
        grid.appendAssumeCapacity(row);
    }
    return grid.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(21, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(40, result);
}
