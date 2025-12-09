const std = @import("std");
const example = @embedFile("examples/09.txt");
const input = @embedFile("inputs/09.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const tiles = try parse(data, allocator);
    var max_area: u64 = 0;
    for (0..tiles.len) |i| {
        const tile = tiles[i];
        for (i + 1..tiles.len) |j| {
            const other = tiles[j];
            const area = get_area(tile, other);
            if (area > max_area) max_area = area;
        }
    }

    return max_area;
}

pub fn part2(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const tiles = try parse(data, allocator);

    var max_area: u64 = 0;
    for (0..tiles.len) |i| {
        const a = tiles[i];
        compare: for (i + 1..tiles.len) |j| {
            const b = tiles[j];
            const corners = get_corners(a, b);
            if (corners.max_i - corners.min_i < 2 or corners.max_j - corners.min_j < 2) continue;

            const min_i = corners.min_i + 1;
            const max_i = corners.max_i - 1;
            const min_j = corners.min_j + 1;
            const max_j = corners.max_j - 1;
            const inner_lines = [_]Line{
                .{ .{ min_i, min_j }, .{ min_i, max_j } },
                .{ .{ min_i, max_j }, .{ max_i, max_j } },
                .{ .{ max_i, max_j }, .{ max_i, min_j } },
                .{ .{ max_i, min_j }, .{ min_i, min_j } },
            };

            for (0..tiles.len - 1) |k| {
                const edge = get_line(tiles[k], tiles[k + 1]) catch continue;
                inline for (inner_lines) |in_line| {
                    if (try intersect(in_line, edge)) continue :compare;
                }
            }
            if (get_line(tiles[tiles.len - 1], tiles[0])) |edge| {
                inline for (inner_lines) |in_line| {
                    if (try intersect(in_line, edge)) continue :compare;
                }
            } else |_| {}

            const area = get_area(a, b);
            if (area > max_area) max_area = area;
        }
    }

    return max_area;
}

const Tile = [2]u64;
const Line = [2]Tile;
const Corners = struct {
    min_i: u64,
    max_i: u64,
    min_j: u64,
    max_j: u64,
};

fn get_area(a: Tile, b: Tile) u64 {
    const corners = get_corners(a, b);

    return (corners.max_i - corners.min_i + 1) * (corners.max_j - corners.min_j + 1);
}

fn get_corners(a: Tile, b: Tile) Corners {
    return Corners{
        .min_i = @min(a[0], b[0]),
        .max_i = @max(a[0], b[0]),
        .min_j = @min(a[1], b[1]),
        .max_j = @max(a[1], b[1]),
    };
}

fn get_line(a: Tile, b: Tile) !Line {
    if (a[0] == b[0] or a[1] == b[1]) {
        return .{ a, b };
    }
    return error.InvalidLine;
}

fn intersect(a: Line, b: Line) !bool {
    const a_vertical = a[0][0] == a[1][0];
    const a_horizontal = a[0][1] == a[1][1];
    const b_vertical = b[0][0] == b[1][0];
    const b_horizontal = b[0][1] == b[1][1];

    // Vertically co-linear
    if (a_vertical and b_vertical) {
        if (a[0][0] != b[0][0]) return false;
        const a_lo = @min(a[0][1], a[1][1]);
        const a_hi = @max(a[0][1], a[1][1]);
        const b_lo = @min(b[0][1], b[1][1]);
        const b_hi = @max(b[0][1], b[1][1]);
        return overlap(a_lo, a_hi, b_lo, b_hi);
    }

    // Horizontally co-linear
    if (a_horizontal and b_horizontal) {
        if (a[0][1] != b[0][1]) return false;
        const a_lo = @min(a[0][0], a[1][0]);
        const a_hi = @max(a[0][0], a[1][0]);
        const b_lo = @min(b[0][0], b[1][0]);
        const b_hi = @max(b[0][0], b[1][0]);
        return overlap(a_lo, a_hi, b_lo, b_hi);
    }

    // Crossing
    var v = a;
    var h = b;
    if (a_horizontal and b_vertical) {
        v = b;
        h = a;
    } else if (!(a_vertical and b_horizontal)) {
        return error.GeometryError;
    }

    // Geometry check!
    const i = v[0][0];
    const j = h[0][1];
    const h_lo = @min(h[0][0], h[1][0]);
    const h_hi = @max(h[0][0], h[1][0]);
    const v_lo = @min(v[0][1], v[1][1]);
    const v_hi = @max(v[0][1], v[1][1]);
    return (h_lo <= i and i <= h_hi) and (v_lo <= j and j <= v_hi);
}

fn overlap(lo1: u64, hi1: u64, lo2: u64, hi2: u64) bool {
    return !(hi1 < lo2 or hi2 < lo1);
}

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]const Tile {
    var out = try std.ArrayList(Tile).initCapacity(allocator, 2);
    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var tokens = std.mem.tokenizeScalar(u8, line, ',');
        const i = try std.fmt.parseInt(u64, tokens.next() orelse "", 10);
        const j = try std.fmt.parseInt(u64, tokens.next() orelse "", 10);

        try out.append(allocator, .{ i, j });
    }

    return out.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(50, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(24, result);
}
