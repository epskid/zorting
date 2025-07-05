const array = @import("../array.zig");

// Cirua gaps (+1750 from Roman Dovgopol) (see https://oeis.org/A102549)
const gaps = [_]usize{ 1750, 701, 301, 132, 57, 23, 10, 4, 1, 0 };

var current_gap: usize = 0;
var i: usize = 0;
var j: usize = 0;
var temp: ?u32 = null;

pub fn init(_: *const array.Array) !void {
    current_gap = 0;
    i = gaps[0];
    j = 0;
    temp = null;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (gaps[current_gap] == 0) {
        return true;
    }
    if (i >= arr.len) {
        current_gap += 1;
        i = gaps[current_gap];
        return false;
    }
    if (temp) |tmp| {
        if (j < gaps[current_gap] or arr.get(j - gaps[current_gap]) <= tmp) {
            arr.set(j, tmp);
            temp = null;
            i += 1;
        } else {
            arr.set(j, arr.get(j - gaps[current_gap]));
        }
        j -|= gaps[current_gap];
        arr.comparisons += 1;
        return false;
    } else {
        temp = arr.get(i);
        j = i;
        return false;
    }

    return false;
}
