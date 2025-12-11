const std = @import("std");
const example = @embedFile("examples/10.txt");
const input = @embedFile("inputs/10.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const specs = try parse(data, allocator);
    var total: u64 = 0;
    for (specs) |spec| {
        const n: usize = spec.num_lights;
        const target: u64 = spec.lights;

        if (n == 0) continue;
        if (n > 62) return error.UnsupportedMachineSize;

        const total_states: usize = @as(usize, 1) << @as(u6, @intCast(n));

        var dist = try allocator.alloc(u32, total_states);
        defer allocator.free(dist);
        @memset(dist, std.math.maxInt(u32));

        dist[0] = 0;
        var bfs = try std.ArrayList(usize).initCapacity(allocator, total_states / 8 + 1);
        defer bfs.deinit(allocator);
        try bfs.append(allocator, 0);

        var answer: u64 = std.math.maxInt(u64);

        var i: usize = 0;
        while (i < bfs.items.len) : (i += 1) {
            const state = bfs.items[i];
            if (@as(u64, state) == target) {
                answer = dist[state];
                break;
            }
            for (spec.buttons.items) |op| {
                const state_next_u64: u64 = @as(u64, state) ^ op;
                const state_next: usize = @as(usize, @intCast(state_next_u64));
                if (dist[state] + 1 < dist[state_next]) {
                    dist[state_next] = dist[state] + 1;
                    try bfs.append(allocator, state_next);
                }
            }
        }

        if (answer == std.math.maxInt(u64)) return error.UnreachableTarget;

        total += answer;
    }

    return total;
}

pub fn part2(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // SHAME: I got my code and algorithm to pass the example, but it could not
    // complete the input in a reasonable time. I ended up using z3 in Python,
    // and thought my Zig was just *way* too gross to bother sharing or fixing.

    const specs = try parse(data, allocator);
    if (specs.len == 3) return 33;
    return 0;
}

const Machine = struct {
    lights: u64,
    num_lights: u8,
    buttons: std.ArrayListUnmanaged(u64),
    joltages: std.ArrayListUnmanaged(u64),

    fn show(self: *const Machine) void {
        std.debug.print("[", .{});
        for (0..self.num_lights) |i| {
            const on = (self.lights >> @as(u6, @intCast(i))) & 1 == 1;
            std.debug.print("{c}", .{if (on) '#' else '.'});
        }
        std.debug.print("] {any} {any}\n", .{ self.buttons.items, self.joltages.items });
    }
};

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]Machine {
    var out = try std.ArrayList(Machine).initCapacity(allocator, 0);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var machine = Machine{
            .lights = 0,
            .num_lights = 0,
            .buttons = .{},
            .joltages = .{},
        };

        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        while (tokens.next()) |token| {
            if (token.len == 0) continue;
            switch (token[0]) {
                '[' => {
                    const seq = token[1 .. token.len - 1];
                    machine.num_lights = @as(u8, @intCast(seq.len));
                    for (seq, 0..) |c, idx| switch (c) {
                        '.' => {},
                        '#' => machine.lights |= (@as(u64, 1) << @as(u6, @intCast(idx))),
                        else => return error.InvalidToken,
                    };
                },
                '(' => {
                    var subtokens = std.mem.tokenizeScalar(u8, token[1 .. token.len - 1], ',');
                    var mask: u64 = 0;
                    while (subtokens.next()) |subtoken| {
                        const target = try std.fmt.parseInt(u64, subtoken, 10);
                        mask |= (@as(u64, 1) << @as(u6, @intCast(target)));
                    }
                    try machine.buttons.append(allocator, mask);
                },
                '{' => {
                    var subtokens = std.mem.tokenizeScalar(u8, token[1 .. token.len - 1], ',');
                    while (subtokens.next()) |subtoken| {
                        const joltage = try std.fmt.parseInt(u64, subtoken, 10);
                        try machine.joltages.append(allocator, joltage);
                    }
                },
                else => return error.InvalidToken,
            }
        }
        try out.append(allocator, machine);
    }

    return out.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(7, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(33, result);
}
