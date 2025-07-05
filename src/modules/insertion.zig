const array = @import("../array.zig");

var i: usize = 0;
var j: ?usize = null;

pub fn init(_: *const array.Array) !void {
    i = 1;
    j = null;
}

pub fn deinit() void {}

pub fn step(arr: *array.Array) bool {
    if (i >= arr.len) {
        return true;
    }
    if (j) |*jj| {
        if (jj.* == 0 or arr.get(jj.* - 1) < arr.get(jj.*)) {
            j = null;
            i += 1;
        } else {
            arr.swap(jj.*, jj.* - 1);
            jj.* -|= 1;
        }
        arr.comparisons += 1;
        return false;
    } else {
        j = i;
    }

    return false;
}
