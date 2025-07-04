const array = @import("array.zig");

pub const AlgorithmType = blk: {
    var fields: [@typeInfo(modules.modules).@"struct".decls.len]std.builtin.Type.EnumField = undefined;
    for (@typeInfo(modules.modules).@"struct".decls, 0..) |decl, i| {
        fields[i].name = decl.name;
        fields[i].value = i;
    }

    break :blk @Type(.{ .@"enum" = .{ .decls = &.{}, .tag_type = i32, .fields = &fields, .is_exhaustive = true } });
};
pub const selection_string = blk: {
    var s: [:0]const u8 = "";
    const field_names = std.meta.fieldNames(AlgorithmType);
    for (field_names, 0..) |name, idx| {
        s = s ++ name;
        if (idx < field_names.len - 1) {
            s = s ++ ";";
        }
    }

    break :blk s;
};

const std = @import("std");
const modules = @import("modules/modules.zig");
