const std = @import("std");
const example = @embedFile("examples/01.txt");
const input = @embedFile("inputs/01.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !i16 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const instructions = try parse(data, allocator);
    defer allocator.free(instructions);

    var count: i16 = 0;
    var dial: i16 = 50;

    for (instructions) |instruction| {
        dial = @mod(dial + instruction, 100);
        if (dial == 0) count += 1;
    }
    return count;
}

pub fn part2(data: []const u8) !i16 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const instructions = try parse(data, allocator);
    defer allocator.free(instructions);

    var count: i16 = 0;
    var dial: i16 = 50;

    for (instructions) |instruction| {
        const sign: i16 = if (instruction < 0) -1 else 1;
        const rotations: i16 = @intCast(@abs(instruction));
        count += @divTrunc(rotations, 100);

        const rem: i16 = @mod(rotations, 100) * sign;
        if (rem == 0) continue;

        const offset = dial + rem;
        if (dial != 0 and (offset <= 0 or offset >= 100)) count += 1;

        dial = @mod(offset, 100);
    }
    return count;
}

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]const i16 {
    var list = try std.ArrayList(i16).initCapacity(allocator, 0);
    defer list.deinit(allocator);

    var it = std.mem.splitScalar(u8, data, '\n');
    while (it.next()) |ln| {
        if (ln.len == 0) continue;
        const sign: i16 = if (ln[0] == 'L') -1 else if (ln[0] == 'R') 1 else return error.InvalidInstruction;
        const steps = try std.fmt.parseInt(i16, ln[1..], 10);
        try list.append(allocator, sign * steps);
    }
    return list.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(3, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(6, result);
}
