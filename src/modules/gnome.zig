const array = @import("../array.zig");

var index: usize = 0;

pub fn init(_: *const array.Array) !void {
    index = 1;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (index < arr.len) {
        if (index == 0 or arr.get(index) >= arr.get(index - 1)) {
            index += 1;
        } else {
            arr.swap(index, index - 1);
            index -= 1;
        }
        arr.comparisons += 1;
        arr.colors[index] = .green;
    } else {
        return true;
    }

    return false;
}
