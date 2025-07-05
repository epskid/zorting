const modules = @import("modules/modules.zig");
const algorithms = @import("algorithms.zig");
const array = @import("array.zig");

pub fn main() !void {
    const width = 1920;
    const height = 1080;

    rl.initWindow(width, height, "ZORTING");
    defer rl.closeWindow();
    rl.toggleFullscreen();

    rg.loadStyle("style_dark.rgs");
    rg.setStyle(.dropdownbox, .{ .control = .text_alignment }, @intFromEnum(rg.TextAlignment.left));
    rg.setStyle(.dropdownbox, .{ .control = .text_padding }, 5);

    var algorithm: i32 = 0;
    var changing_algorithm = false;
    var running = false;
    var arr: array.Array = array.Array.init(10);
    var sleep_micros: f32 = 1;
    var size: f32 = 1;
    var timer = try std.time.Timer.start();

    defer if (modules.needs_deinit) {
        modules.deinit(@intCast(algorithm));
    };

    arr.ascending();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        if (running) {
            if (@divTrunc(timer.read(), 1000) >= @as(u64, @intFromFloat(sleep_micros))) {
                arr.resetColors();
                running = !modules.step(@intCast(algorithm), &arr);
                timer.reset();
            }
        } else {
            rg.unlock();
        }

        arr.draw();

        if (!running or (rl.getMouseX() < 630 and rl.getMouseY() < 130)) {
            rl.drawRectangle(0, 0, 630, 130, .dark_gray);
            rl.drawText(rl.textFormat("comparisons: %i\narray accesses: %i", .{ arr.comparisons, arr.accesses }), 10, 85, 16, .white);

            if (running) {
                rg.unlock();
            }
            _ = rg.slider(.{ .width = 500, .height = 30, .x = 75, .y = 50 }, "min delay", rl.textFormat("%i", .{@as(i32, @intFromFloat(sleep_micros))}), &sleep_micros, 0, 100000);
            if (running) {
                rg.lock();
            }

            if (rg.dropdownBox(.{ .width = 135, .height = 30, .x = 10, .y = 10 }, algorithms.selection_string, &algorithm, changing_algorithm) != 0) {
                changing_algorithm = !changing_algorithm;
            }

            if (rg.slider(.{ .width = 150, .height = 30, .x = 185, .y = 10 }, "size", rl.textFormat("%i", .{@as(i32, @intFromFloat(size)) * 10}), &size, 1, 200) != 0) {
                arr.len = @intFromFloat(size);
                arr.len *= 10;
                arr.ascending();
                arr.resetColors();
            }
            if (rg.button(.{ .width = 120, .height = 30, .x = 370, .y = 10 }, "shuffle")) {
                arr.shuffle();
            }
            if (!running) {
                if (rg.button(.{ .width = 120, .height = 30, .x = 500, .y = 10 }, "start")) {
                    running = true;
                    try modules.init(@intCast(algorithm), &arr);
                    arr.resetCounters();
                }
            } else {
                rg.unlock();
                if (rg.button(.{ .width = 120, .height = 30, .x = 500, .y = 10 }, "stop")) {
                    running = false;
                }
                rg.lock();
            }
        }

        if (!running and modules.needs_deinit) {
            modules.deinit(@intCast(algorithm));
        }
    }
}

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
