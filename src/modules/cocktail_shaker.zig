const array = @import("../array.zig");
const std = @import("std");

var index: usize = 0;
var backwards = false;
var swapped = false;

var begin_index: usize = 0;
var end_index: usize = 0;

var new_begin_index: usize = 0;
var new_end_index: usize = 0;

pub fn init(arr: *const array.Array) !void {
    index = 0;
    backwards = false;
    swapped = false;

    begin_index = 0;
    end_index = arr.len - 1;

    new_begin_index = end_index;
    new_end_index = begin_index;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (!backwards and index == end_index) {
        const done = !swapped;
        swapped = false;

        backwards = true;
        index -= 1;
        end_index = new_end_index;

        return done;
    } else if (backwards and index == begin_index) {
        const done = !swapped;
        swapped = false;

        backwards = false;
        begin_index = new_begin_index;

        return done;
    }

    if (arr.get(index) > arr.get(index + 1)) {
        swapped = true;
        arr.swap(index, index + 1);
        if (!backwards) {
            new_end_index = index;
        } else {
            new_begin_index = index;
        }
    }
    arr.comparisons += 1;

    if (!backwards) {
        index += 1;
    } else {
        index -= 1;
    }

    return false;
}
