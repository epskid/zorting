const array = @import("../array.zig");

const LRPair = struct {
    left: usize,
    right: usize,
};

var stack: std.ArrayList(LRPair) = undefined;
var partitionPair: ?LRPair = null;

pub fn init(arr: *const array.Array) !void {
    stack = try std.ArrayList(LRPair).initCapacity(std.heap.page_allocator, arr.len);
    try stack.append(.{ .left = 0, .right = arr.len - 1 });
    partitionPair = null;
}

pub fn deinit() void {
    stack.deinit();
}

fn partition(arr: *array.Array, lo: usize, hi: usize) ?usize {
    const pivot = arr.get(lo);
    arr.colors[pivot] = .green;

    if (partitionPair) |*pair| {
        if (arr.get(pair.left) < pivot) {
            pair.left += 1;
            arr.comparisons += 1;
            return null;
        }
        if (arr.get(pair.right) > pivot) {
            pair.right -= 1;
            arr.comparisons += 1;
            return null;
        }
        if (pair.left >= pair.right) {
            return pair.right;
        }

        arr.swap(pair.left, pair.right);
    } else {
        partitionPair = .{ .left = lo, .right = hi };
        return null;
    }

    return null;
}

pub fn step(arr: *array.Array) bool {
    const pair = stack.getLastOrNull() orelse return true;
    const left = pair.left;
    const right = pair.right;

    if (left > right) {
        return true;
    }

    if (partition(arr, left, right)) |pivot| {
        _ = stack.pop();
        partitionPair = null;

        stack.append(.{
            .left = left,
            .right = pivot,
        }) catch unreachable;
        stack.append(.{
            .left = pivot + 1,
            .right = right,
        }) catch unreachable;
    }

    return false;
}

const std = @import("std");
