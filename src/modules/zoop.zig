// not a sorting algorithm, just the zoop at the end.
const array = @import("../array.zig");

var index: usize = 0;
pub var going: bool = false;

pub fn init() void {
    index = 0;
    going = true;
}

pub fn step(arr: *array.Array) bool {
    arr.colors[index] = .red;
    @memset(arr.colors[0..index], .green);
    _ = arr.get(index);
    index += 1;

    return index == arr.len;
}
