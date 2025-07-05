const array = @import("../array.zig");

var index: usize = 0;
var swapped = false;
var backwards = false;
var sorted: usize = 0;

pub fn init(_: *const array.Array) !void {
    index = 0;
    swapped = false;
    backwards = false;
    sorted = 0;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (!backwards and index == arr.len - 1 - sorted) {
        const done = !swapped;
        swapped = false;
        backwards = true;
        index -= 1;
        return done;
    } else if (backwards and index == sorted) {
        const done = !swapped;
        swapped = false;
        backwards = false;
        sorted += 1;
        return done;
    }

    if (arr.get(index) > arr.get(index + 1)) {
        swapped = true;
        arr.swap(index, index + 1);
    }
    arr.comparisons += 1;

    if (!backwards) {
        index += 1;
    } else {
        index -= 1;
    }

    return false;
}
