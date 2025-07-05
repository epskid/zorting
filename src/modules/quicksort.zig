const array = @import("../array.zig");

const LRPair = struct {
    left: usize,
    right: usize,
};

var stack: std.ArrayList(LRPair) = undefined;
var i: ?usize = null;
var j: usize = 0;

pub fn init(arr: *const array.Array) !void {
    stack = try std.ArrayList(LRPair).initCapacity(std.heap.page_allocator, arr.len);
    try stack.append(.{ .left = 0, .right = arr.len - 1 });
    i = null;
    j = 0;
}

pub fn deinit() void {
    stack.deinit();
}

fn partition(arr: *array.Array, lo: usize, hi: usize) ?usize {
    const pivot = arr.get(hi);
    arr.colors[hi] = .green;

    if (i) |*ii| {
        if (j > hi - 1) {
            arr.swap(ii.*, hi);
            return ii.*;
        }

        if (arr.get(j) <= pivot) {
            arr.swap(ii.*, j);
            ii.* += 1;
        }
        arr.comparisons += 1;

        j += 1;
    } else {
        i = lo;
        j = lo;
        return null;
    }

    return null;
}

pub fn step(arr: *array.Array) bool {
    const pair = stack.getLastOrNull() orelse return true;
    const lo = pair.left;
    const hi = pair.right;

    if (lo >= hi) {
        _ = stack.pop();
        return false;
    }

    if (hi - lo == 1) {
        _ = stack.pop();
        if (arr.get(lo) > arr.get(hi)) {
            arr.swap(lo, hi);
        }
        return false;
    }

    if (partition(arr, lo, hi)) |pivot| {
        _ = stack.pop();
        i = null;

        stack.append(.{
            .left = pivot + 1,
            .right = hi,
        }) catch unreachable;
        if (pivot != 0) {
            stack.append(.{
                .left = lo,
                .right = pivot - 1,
            }) catch unreachable;
        }
    }

    return false;
}

const std = @import("std");
