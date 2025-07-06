const modules = @import("modules/modules.zig");
const app = @import("app.zig");

pub fn main() !void {
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(640, 480, "ZORTING");
    defer rl.closeWindow();

    const monitor = rl.getCurrentMonitor();
    rl.setWindowSize(rl.getMonitorWidth(monitor), rl.getMonitorHeight(monitor));
    rl.toggleFullscreen();

    rg.loadStyle("resources/style_dark.rgs");
    rg.setStyle(.dropdownbox, .{ .control = .text_alignment }, @intFromEnum(rg.TextAlignment.left));
    rg.setStyle(.dropdownbox, .{ .control = .text_padding }, 5);

    var zorting = try app.App.init();
    defer modules.deinit();

    if (builtin.os.tag != .wasi and builtin.os.tag != .emscripten) {
        while (!rl.windowShouldClose()) {
            try zorting.update();
        }
    } else {
        const emscripten = std.os.emscripten;
        emscripten.emscripten_set_main_loop_arg(&app.App.updateEmscripten, &zorting, 0, 1);
    }
}

const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");
const rg = @import("raygui");
