const std = @import("std");
const example = @embedFile("examples/06.txt");
const input = @embedFile("inputs/06.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Parse
    var rows = try std.ArrayList([]u64).initCapacity(allocator, 0);
    var ops = try std.ArrayList(u8).initCapacity(allocator, 0);

    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        var tokens = std.mem.tokenizeScalar(u8, trimmed, ' ');
        if (std.ascii.isDigit(trimmed[0])) {
            var row = try std.ArrayList(u64).initCapacity(allocator, 4);
            defer row.deinit(allocator);
            while (tokens.next()) |t| {
                if (t.len == 0) continue;
                const value = try std.fmt.parseInt(u64, t, 10);
                try row.append(allocator, value);
            }
            const owned = try row.toOwnedSlice(allocator);
            try rows.append(allocator, owned);
        } else {
            while (tokens.next()) |t| {
                if (t.len == 0) continue;
                try ops.append(allocator, t[0]);
            }
        }
    }

    // Calculate
    var subtotals = try allocator.alloc(u64, ops.items.len);
    defer allocator.free(subtotals);
    for (ops.items, 0..) |op, i| {
        subtotals[i] = switch (op) {
            '+' => 0,
            '*' => 1,
            else => return error.InvalidOperator,
        };
    }

    for (rows.items) |row_vals| {
        for (row_vals, 0..) |value, col| {
            const op = ops.items[col];
            switch (op) {
                '+' => subtotals[col] += value,
                '*' => subtotals[col] *= value,
                else => return error.InvalidOperator,
            }
        }
    }

    var sum: u64 = 0;
    for (subtotals) |item| sum += item;
    return sum;
}

pub fn part2(data: []const u8) !u64 {
    // NOTE: wow, this was very, very ugly and far from idiomatic. I'm not sure
    // yet how to write more functional style code with Zig and I think a more
    // elegant solution might be to transpose the sheet across the diagonal and
    // then parse and calculate in one pass, but I was having trouble with it
    // being such a newbie!
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Parse
    var sheet = try std.ArrayList([]const u8).initCapacity(allocator, 0);

    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try sheet.append(allocator, line);
    }

    const num_rows = sheet.items.len - 1;
    const ops_line = sheet.items[num_rows];

    // Collect positions
    var positions = try std.ArrayList(usize).initCapacity(allocator, 0);
    defer positions.deinit(allocator);
    var ops = try std.ArrayList(u8).initCapacity(allocator, 0);
    defer ops.deinit(allocator);

    for (ops_line, 0..) |c, idx| {
        if (c != ' ') {
            try positions.append(allocator, idx);
            try ops.append(allocator, c);
        }
    }

    // Calculate
    var buffer = try allocator.alloc(u8, num_rows);
    defer allocator.free(buffer);

    var sum: u64 = 0;

    for (ops.items, 0..) |op, i| {
        const start = positions.items[i];
        const end: usize = if (i + 1 < positions.items.len)
            positions.items[i + 1]
        else
            ops_line.len;

        if (end <= start) continue;

        var acc: u64 = switch (op) {
            '+' => 0,
            '*' => 1,
            else => return error.InvalidOperator,
        };

        var col: usize = start;
        while (col < end) : (col += 1) {
            for (0..num_rows) |r| {
                buffer[r] = sheet.items[r][col];
            }

            const trimmed = std.mem.trim(u8, buffer[0..num_rows], " ");
            if (trimmed.len == 0) continue;

            const value = try std.fmt.parseInt(u64, trimmed, 10);
            switch (op) {
                '+' => acc += value,
                '*' => acc *= value,
                else => return error.InvalidOperator,
            }
        }

        sum += acc;
    }

    return sum;
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(4277556, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(3263827, result);
}
