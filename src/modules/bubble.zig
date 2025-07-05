const array = @import("../array.zig");

var index: usize = 0;
var swapped = false;

pub fn init(_: *const array.Array) !void {
    index = 0;
    swapped = false;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (index == arr.len - 1) {
        const done = !swapped;
        swapped = false;
        index = 0;
        return done;
    }

    if (arr.get(index) > arr.get(index + 1)) {
        swapped = true;
        arr.swap(index, index + 1);
    }
    arr.comparisons += 1;

    index += 1;

    return false;
}
