const modules = @import("modules/modules.zig");
const app = @import("app.zig");

pub fn main() !void {
    const width = 1920;
    const height = 1080;

    rl.initWindow(width, height, "ZORTING");
    defer rl.closeWindow();
    rl.toggleFullscreen();

    rg.loadStyle("resources/style_dark.rgs");
    rg.setStyle(.dropdownbox, .{ .control = .text_alignment }, @intFromEnum(rg.TextAlignment.left));
    rg.setStyle(.dropdownbox, .{ .control = .text_padding }, 5);

    var zorting = try app.App.init();
    defer modules.deinit();

    while (!rl.windowShouldClose()) {
        try zorting.update();
    }
}

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
