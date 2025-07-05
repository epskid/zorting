const array = @import("../array.zig");

var sorted: usize = 0;
var sorting: usize = 0;
var currentMin: usize = 0;

pub fn init(_: *const array.Array) !void {
    sorted = 0;
    sorting = 0;
    currentMin = 0;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (sorted == arr.len - 1) {
        return true;
    }

    if (sorting == arr.len) {
        if (currentMin != sorted) {
            arr.swap(currentMin, sorted);
        }
        sorted += 1;
        sorting = sorted;
        currentMin = sorting;
    }

    if (arr.get(sorting) < arr.get(currentMin)) {
        currentMin = sorting;
    }
    arr.comparisons += 1;

    arr.colors[currentMin] = .green;

    sorting += 1;
    return false;
}
