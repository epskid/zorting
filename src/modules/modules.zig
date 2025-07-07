const array = @import("../array.zig");
const zoop = @import("zoop.zig");

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

    // mergelikes
    pub const bitonic = @import("bitonic.zig");

    // evil hell section for evil algorithms
    pub const bogo = @import("bogo.zig");
};

const decls = @typeInfo(modules).@"struct".decls;

pub const selection_string = blk: {
    var s: [:0]const u8 = "";
    for (decls, 0..) |decl, idx| {
        s = s ++ decl.name;
        if (idx < decls.len - 1) {
            s = s ++ ";";
        }
    }

    break :blk s;
};

var working_on: ?i32 = null;

pub fn init(module_index: i32, arr: *const array.Array) !void {
    deinit();
    inline for (decls, 0..) |decl, idx| {
        if (idx == module_index) {
            const module = @field(modules, decl.name);
            try module.init(arr);
        }
    }

    if (module_index >= decls.len) {
        @panic("module out of bounds");
    }

    working_on = module_index;
}

pub fn deinit() void {
    if (working_on) |module_index| {
        inline for (decls, 0..) |decl, idx| {
            if (idx == module_index) {
                const module = @field(modules, decl.name);
                module.deinit();
            }
        }

        working_on = null;
    }
}

pub fn step(arr: *array.Array) bool {
    if (zoop.going) {
        const done = zoop.step(arr);
        zoop.going = !done;
        return done;
    }

    if (working_on) |module_index| {
        inline for (decls, 0..) |decl, idx| {
            if (idx == module_index) {
                const module = @field(modules, decl.name);
                const done = module.step(arr);
                if (done) {
                    deinit();
                    zoop.init();
                }
                return false;
            }
        }
        unreachable;
    }
    @panic("tried to step without module");
}
