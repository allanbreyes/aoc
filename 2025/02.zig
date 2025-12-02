const std = @import("std");
const example = @embedFile("examples/02.txt");
const input = @embedFile("inputs/02.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const ranges = try parse(data, allocator);
    defer allocator.free(ranges);

    var sum: u64 = 0;
    for (ranges) |range| {
        var id = range[0];
        const end = range[1];
        while (id <= end) : (id += 1) {
            const n: u64 = std.math.log10_int(id) + 1;
            if (n % 2 != 0) continue;

            const mask = try std.math.powi(u64, 10, n / 2);
            const left = id / mask;
            const right = id % mask;
            if (left == right) sum += id;
        }
    }

    return sum;
}

pub fn part2(data: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const ranges = try parse(data, allocator);
    defer allocator.free(ranges);

    var sum: u64 = 0;
    for (ranges) |range| {
        var id = range[0];
        const end = range[1];
        while (id <= end) : (id += 1) {
            const n: u64 = std.math.log10_int(id) + 1;

            var size: u64 = 1;
            groups: while (size < n) : (size += 1) {
                if (n % size != 0) continue;
                const m = n / size;
                const mask = try std.math.powi(u64, 10, size);

                const value = id % mask;
                var x = id;

                for (1..m) |_| {
                    x = x / mask;
                    if (x % mask != value) {
                        continue :groups;
                    }
                }

                sum += id;
                break;
            }
        }
    }

    return sum;
}

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]const [2]u64 {
    var list = try std.ArrayList([2]u64).initCapacity(allocator, 0);
    defer list.deinit(allocator);

    const whitespace = " \t\n\r";
    const line = std.mem.trim(u8, data, whitespace);

    var ranges = std.mem.splitScalar(u8, line, ',');
    while (ranges.next()) |range| {
        if (range.len == 0) continue;

        const i = std.mem.indexOfScalar(u8, range, '-') orelse return error.InvalidRange;
        const start = try std.fmt.parseInt(u64, range[0..i], 10);
        const end = try std.fmt.parseInt(u64, range[i + 1 ..], 10);
        try list.append(allocator, [_]u64{ start, end });
    }

    return list.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(1227775554, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(4174379265, result);
}
