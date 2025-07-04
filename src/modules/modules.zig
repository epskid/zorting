const array = @import("../array.zig");

pub const modules = struct {
    pub const bubble_sort = @import("bubble_sort.zig");
    pub const quick_sort = @import("quick_sort.zig");
    pub const bogo_sort = @import("bogo_sort.zig");
};

pub fn deinit(module_index: usize) void {
    inline for (@typeInfo(modules).@"struct".decls, 0..) |decl, idx| {
        if (idx == module_index) {
            const module = @field(modules, decl.name);
            module.deinit();
        }
    }
}

pub fn init(module_index: usize, arr: *const array.Array) !void {
    inline for (@typeInfo(modules).@"struct".decls, 0..) |decl, idx| {
        if (idx == module_index) {
            const module = @field(modules, decl.name);
            try module.init(arr);
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
