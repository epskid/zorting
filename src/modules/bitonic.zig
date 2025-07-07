const array = @import("../array.zig");

var i: usize = 0;
var j: usize = 0;
var k: usize = 0;

pub fn init(_: *const array.Array) !void {
    k = 2;
    j = 0;
    i = 0;
}

pub fn deinit() void {}

fn compareAndSwap(arr: *array.Array, a: usize, b: usize) void {
    if (a < b and b < arr.len and arr.get(b) < arr.get(a)) {
        arr.swap(a, b);
    }
    arr.comparisons += 1;
}

pub fn step(arr: *array.Array) bool {
    if (k >> 1 >= arr.len) {
        return true;
    }
    if (j == 0) {
        if (i >= arr.len) {
            i = 0;
            j = k >> 1;
            return false;
        }
        compareAndSwap(arr, i, i ^ (k - 1));

        i += 1;
    } else {
        if (i >= arr.len) {
            i = 0;
            j >>= 1;
            if (j == 0) {
                k <<= 1;
            }
            return false;
        }
        compareAndSwap(arr, i, i ^ j);

        i += 1;
    }

    return false;
}
