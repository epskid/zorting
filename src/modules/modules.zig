const array = @import("../array.zig");

const modules = struct {
    // bubblelikes
    pub const bubble = @import("bubble.zig");
    pub const cocktail_shaker = @import("cocktail_shaker.zig");

    // quicksort
    pub const quick = @import("quick.zig");

    // selection sort
    pub const selection = @import("selection.zig");

    // insertionlikes
    pub const insertion = @import("insertion.zig");
    pub const gnome = @import("gnome.zig");
    pub const shell = @import("shell.zig");

    // evil hell section for evil algorithms
    pub const bogo = @import("bogo.zig");
};

pub const selection_string = blk: {
    var s: [:0]const u8 = "";
    const decls = @typeInfo(modules).@"struct".decls;
    for (decls, 0..) |decl, idx| {
        s = s ++ decl.name;
        if (idx < decls.len - 1) {
            s = s ++ ";";
        }
    }

    break :blk s;
};

pub var needs_deinit = false;

pub fn init(module_index: usize, arr: *const array.Array) !void {
    needs_deinit = true;
    inline for (@typeInfo(modules).@"struct".decls, 0..) |decl, idx| {
        if (idx == module_index) {
            const module = @field(modules, decl.name);
            try module.init(arr);
        }
    }
}

pub fn deinit(module_index: usize) void {
    needs_deinit = false;
    inline for (@typeInfo(modules).@"struct".decls, 0..) |decl, idx| {
        if (idx == module_index) {
            const module = @field(modules, decl.name);
            module.deinit();
        }
    }
}

pub fn step(module_index: usize, arr: *array.Array) bool {
    inline for (@typeInfo(modules).@"struct".decls, 0..) |decl, idx| {
        if (idx == module_index) {
            const module = @field(modules, decl.name);
            return module.step(arr);
        }
    }

    unreachable;
}
