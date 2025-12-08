const std = @import("std");
const example = @embedFile("examples/08.txt");
const input = @embedFile("inputs/08.txt");

pub fn main() !void {
    std.debug.print("part1: {d}\n", .{try part1(input)});
    std.debug.print("part2: {d}\n", .{try part2(input)});
}

pub fn part1(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const boxes = try parse(data, allocator);
    std.sort.pdq(Box, boxes, {}, box_less);
    const edges = try build_sorted_edges(boxes, allocator);

    const n = boxes.len;
    if (n == 0) return 0;
    var dsu = try DisjointSet.init(allocator, n);

    const edge_limit: usize = if (n == 20) 10 else 1000;
    const limit: usize = @min(edges.len, edge_limit);
    for (0..limit) |idx| {
        const a = edges[idx].i;
        const b = edges[idx].j;
        const ra = dsu.find(a);
        const rb = dsu.find(b);
        if (ra == rb) continue;
        _ = dsu.unite(ra, rb);
    }

    var top = [_]u64{ 0, 0, 0 };
    for (0..n) |i| {
        if (dsu.parents[i] == i) {
            const s = dsu.sizes[i];
            if (s > top[0]) {
                top[2] = top[1];
                top[1] = top[0];
                top[0] = s;
            } else if (s > top[1]) {
                top[2] = top[1];
                top[1] = s;
            } else if (s > top[2]) {
                top[2] = s;
            }
        }
    }

    var product: u64 = 1;
    for (top) |s| {
        if (s == 0) break;
        product *= s;
    }
    return product;
}

pub fn part2(data: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const boxes = try parse(data, allocator);
    std.sort.pdq(Box, boxes, {}, box_less);
    const edges = try build_sorted_edges(boxes, allocator);

    const n = boxes.len;
    if (n == 0) return 0;
    var dsu = try DisjointSet.init(allocator, n);

    for (edges) |e| {
        const ra = dsu.find(e.i);
        const rb = dsu.find(e.j);
        if (ra == rb) continue;
        const root = dsu.unite(ra, rb);
        if (dsu.sizes[root] == n) {
            return boxes[e.i][0] * boxes[e.j][0];
        }
    }

    return error.NoSolution;
}

const Box = [3]u64;
const Edge = struct { i: usize, j: usize, dist: f64 };
const EdgeSortCtx = struct { boxes: []const Box };

const DisjointSet = struct {
    parents: []usize,
    sizes: []u64,

    pub fn init(allocator: std.mem.Allocator, n: usize) !DisjointSet {
        var parents = try allocator.alloc(usize, n);
        var sizes = try allocator.alloc(u64, n);
        for (0..n) |i| {
            parents[i] = i;
            sizes[i] = 1;
        }
        return .{ .parents = parents, .sizes = sizes };
    }

    pub fn find(self: *DisjointSet, v: usize) usize {
        var x = v;
        while (self.parents[x] != x) {
            self.parents[x] = self.parents[self.parents[x]];
            x = self.parents[x];
        }
        return x;
    }

    pub fn unite(self: *DisjointSet, a_root: usize, b_root: usize) usize {
        var ra = a_root;
        var rb = b_root;
        if (ra == rb) return ra;
        if (self.sizes[ra] < self.sizes[rb]) {
            const tmp = ra;
            ra = rb;
            rb = tmp;
        }
        self.parents[rb] = ra;
        self.sizes[ra] += self.sizes[rb];
        return ra;
    }
};

fn build_sorted_edges(boxes: []const Box, allocator: std.mem.Allocator) ![]Edge {
    const n = boxes.len;
    var list = try std.ArrayList(Edge).initCapacity(allocator, (n * (n - 1)) / 2);
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dx = dist(boxes[i][0], boxes[j][0]);
            const dy = dist(boxes[i][1], boxes[j][1]);
            const dz = dist(boxes[i][2], boxes[j][2]);
            const d = std.math.sqrt(dx * dx + dy * dy + dz * dz);
            try list.append(allocator, Edge{ .i = i, .j = j, .dist = d });
        }
    }
    std.sort.pdq(Edge, list.items, EdgeSortCtx{ .boxes = boxes }, edge_less);
    return try list.toOwnedSlice(allocator);
}

fn box_less(_: void, a: Box, b: Box) bool {
    if (a[0] != b[0]) return a[0] < b[0];
    if (a[1] != b[1]) return a[1] < b[1];
    return a[2] < b[2];
}

fn edge_less(ctx: EdgeSortCtx, a: Edge, b: Edge) bool {
    if (a.dist < b.dist) return true;
    if (a.dist > b.dist) return false;
    const a0 = ctx.boxes[a.i];
    const b0 = ctx.boxes[b.i];
    if (!std.mem.eql(u64, &a0, &b0)) return box_less({}, a0, b0);
    const a1 = ctx.boxes[a.j];
    const b1 = ctx.boxes[b.j];
    return box_less({}, a1, b1);
}

fn dist(a: u64, b: u64) f64 {
    return @as(f64, @floatFromInt(a)) - @as(f64, @floatFromInt(b));
}

fn parse(data: []const u8, allocator: std.mem.Allocator) ![]Box {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var out = try std.ArrayList(Box).initCapacity(allocator, 0);
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var tokens = std.mem.tokenizeScalar(u8, line, ',');
        var row: Box = undefined;
        var i: usize = 0;
        while (tokens.next()) |value| {
            if (value.len == 0) continue;
            row[i] = try std.fmt.parseInt(u64, value, 10);
            i += 1;
        }
        std.debug.assert(i == 3);
        try out.append(allocator, row);
    }
    return out.toOwnedSlice(allocator);
}

test "part1" {
    const result = try part1(example);
    try std.testing.expectEqual(40, result);
}

test "part2" {
    const result = try part2(example);
    try std.testing.expectEqual(25272, result);
}
