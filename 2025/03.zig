const std = @import("std");
const example = @embedFile("examples/03.txt");
const input = @embedFile("inputs/03.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    return solve(data, 2);
}

pub fn part2(data: []const u8) !u64 {
    return solve(data, 12);
}

fn solve(data: []const u8, length: usize) !u64 {
    // TODO: figure out a more concise/idiomatic way to do this
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const banks = try parse(data, allocator);
    defer {
        for (banks) |b| allocator.free(b);
        allocator.free(banks);
    }

    const max_length = 16;
    if (length > max_length) return error.InvalidLength;

    var sum: u64 = 0;
    for (banks) |bank| {
        var places: [max_length]usize = undefined;
        for (0..length) |j| {
            places[j] = j;
        }

        for (0..bank.len) |i| {
            const num = bank[i];
            var j: usize = 0;
            while (j < length) : (j += 1) {
                const limit = bank.len - (length - j);
                if (i > places[j] // Jolt place check
                and i <= limit // Range check
                and num > bank[places[j]] // Value check
                ) {
                    var k: usize = j;
                    while (k < length) : (k += 1) places[k] = i + (k - j);
                    break;
                }
            }
        }

        var value: u64 = 0;
        for (0..length) |idx| {
            value = value * 10 + @as(u64, @intCast(bank[places[idx]]));
        }
        sum += value;
    }

    return sum;
}

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]const []u8 {
    var list = try std.ArrayList([]u8).initCapacity(allocator, 0);
    defer list.deinit(allocator);

    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const copy = try allocator.dupe(u8, line);
        for (0..line.len) |i| {
            const digit = try std.fmt.parseInt(u8, line[i .. i + 1], 10);
            copy[i] = digit;
        }
        try list.append(allocator, copy);
    }

    return list.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(357, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(3121910778619, result);
}
