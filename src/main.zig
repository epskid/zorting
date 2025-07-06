const modules = @import("modules/modules.zig");
const app = @import("app.zig");

pub fn main() !void {
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(640, 480, "ZORTING");
    defer rl.closeWindow();

    const monitor = rl.getCurrentMonitor();
    rl.setWindowSize(rl.getMonitorWidth(monitor), rl.getMonitorHeight(monitor));
    if (builtin.os.tag != .wasi and builtin.os.tag != .emscripten) rl.toggleFullscreen();

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
const builtin = @import("builtin");
const rl = @import("raylib");
const rg = @import("raygui");
