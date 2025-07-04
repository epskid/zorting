const array = @import("../array.zig");

pub fn init(_: *const array.Array) !void {}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    arr.shuffle();

    for (0..arr.len - 1) |i| {
        if (arr.get(i) > arr.get(i + 1)) {
            return false;
        }
        arr.comparisons += 1;
    }

    return true;
}
