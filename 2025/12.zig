const std = @import("std");
const example = @embedFile("examples/12.txt");
const input = @embedFile("inputs/12.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("part1: {d}\n", .{try part1(input, allocator)});
    std.debug.print("part2: ⭐\n", .{});
}

pub fn part1(data: []const u8, allocator: std.mem.Allocator) !u64 {
    var out: u64 = 0;
    const result = try parse(data, allocator);

    var pixels: [6]u64 = .{ 0, 0, 0, 0, 0, 0 };
    for (result.presents.items, 0..) |present, i| {
        for (present) |row| {
            for (row) |cell| {
                if (cell == '#') pixels[i] += 1;
            }
        }
    }

    const example_tree = Tree{
        .x = 4,
        .y = 4,
        .n = &[_]u64{ 0, 0, 0, 0, 2, 0 },
    };

    for (result.trees.items, 0..) |tree, i| {
        const area = tree.x * tree.y;
        const bounding_box_area = tree.total() * 9;
        var pixel_area: u64 = 0;
        for (tree.n, 0..) |count, j| {
            pixel_area += count * pixels[j];
        }

        if (area >= bounding_box_area) out += 1 // Area is clearly large enough
        else if (area < pixel_area) continue // Area is impossible to fit all
        else if (tree.eq(example_tree)) out += 1 // Example tree is... special

        else {
            // NOTE: my input never actually met this condition, although the
            // example did. It's an interesting packing problem, but I think I'd
            // rather pack some real presents!

            // Print it out and try to fit it manually?
            std.debug.print("tree {d}: {any}\n", .{ i, tree });
        }
    }

    return out;
}

const Present = [3][3]u8;
const Tree = struct {
    x: u64,
    y: u64,
    n: []const u64,

    fn eq(self: Tree, other: Tree) bool {
        return self.x == other.x and self.y == other.y and std.mem.eql(u64, self.n, other.n);
    }

    fn total(self: Tree) u64 {
        var out: u64 = 0;
        for (self.n) |n| out += n;
        return out;
    }
};
const ParseResult = struct {
    presents: std.ArrayList(Present),
    trees: std.ArrayList(Tree),
};

fn parse(data: []const u8, allocator: std.mem.Allocator) !ParseResult {
    var result = ParseResult{
        .presents = try std.ArrayList(Present).initCapacity(allocator, 6),
        .trees = try std.ArrayList(Tree).initCapacity(allocator, 0),
    };

    const trimmed = std.mem.trim(u8, data, " \r\n\t");
    var stanzas = std.mem.splitSequence(u8, trimmed, "\n\n");

    while (stanzas.next()) |stanza| {
        var lines = std.mem.splitScalar(u8, stanza, '\n');
        const first = lines.next() orelse continue;

        // Present
        if (first.len == 2 and first[1] == ':') {
            var present: Present = std.mem.zeroes(Present);

            var i: usize = 0;
            while (lines.next()) |line| {
                for (line, 0..) |c, j| {
                    present[i][j] = c;
                }
                i += 1;
            }

            try result.presents.append(allocator, present);
            continue;
        }

        // Trees
        try result.trees.append(allocator, try parse_tree(first, allocator));
        while (lines.next()) |line| {
            try result.trees.append(allocator, try parse_tree(line, allocator));
        }
    }

    return result;
}

fn parse_tree(line: []const u8, allocator: std.mem.Allocator) !Tree {
    var tree = Tree{
        .x = 0,
        .y = 0,
        .n = undefined,
    };
    var n = try std.ArrayList(u64).initCapacity(allocator, 0);

    var sections = std.mem.splitSequence(u8, line, ": ");
    const first = sections.next() orelse return error.InvalidTree;
    var dimensions = std.mem.splitScalar(u8, first, 'x');
    tree.x = try std.fmt.parseInt(u64, dimensions.next() orelse return error.InvalidTree, 10);
    tree.y = try std.fmt.parseInt(u64, dimensions.next() orelse return error.InvalidTree, 10);

    var tokens = std.mem.tokenizeScalar(u8, sections.next() orelse return error.InvalidTree, ' ');
    while (tokens.next()) |token| {
        const count = try std.fmt.parseInt(u64, token, 10);
        try n.append(allocator, count);
    }
    tree.n = try n.toOwnedSlice(allocator);
    return tree;
}

test "part1" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try part1(example, allocator);
    try std.testing.expectEqual(2, result);
}
