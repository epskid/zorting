const array = @import("../array.zig");

var idx: usize = 0;

pub fn init(_: *const array.Array) !void {
    idx = 0;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (idx < arr.len - 1) {
        arr.comparisons += 1;
        if (arr.get(idx) > arr.get(idx + 1)) {
            arr.shuffle();
            idx = 0;
        } else {
            idx += 1;
        }
        return false;
    } else {
        return true;
    }
}
