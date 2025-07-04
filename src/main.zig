const modules = @import("modules/modules.zig");
const algorithms = @import("algorithms.zig");
const array = @import("array.zig");

pub fn main() !void {
    const width = 1920;
    const height = 1080;

    rl.initWindow(width, height, "ZORTING");
    defer rl.closeWindow();
    rl.toggleFullscreen();

    var algorithm: i32 = 0;
    var changing_algorithm = false;
    var prev_running = false;
    var running = false;
    var arr: array.Array = array.Array.init(10);
    var sleep_micros: f32 = 1;
    var elements: f32 = 1;
    var timer = try std.time.Timer.start();

    arr.ascending();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        prev_running = running;
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

        if (rg.dropdownBox(.{ .width = 120, .height = 30, .x = 10, .y = 10 }, algorithms.selection_string, &algorithm, changing_algorithm) != 0) {
            changing_algorithm = !changing_algorithm;
        }

        if (running) {
            rg.unlock();
        }
        _ = rg.slider(.{ .width = 130, .height = 30, .x = 190, .y = 10 }, "min delay", rl.textFormat("%i", .{@as(i32, @intFromFloat(sleep_micros))}), &sleep_micros, 0, 100000);
        if (running) {
            rg.lock();
        }

        if (rg.slider(.{ .width = 150, .height = 30, .x = 415, .y = 10 }, "elements", rl.textFormat("%i", .{@as(i32, @intFromFloat(elements)) * 10}), &elements, 1, 100) != 0) {
            arr.len = @intFromFloat(elements);
            arr.len *= 10;
            arr.ascending();
        }
        if (rg.button(.{ .width = 120, .height = 30, .x = 600, .y = 10 }, "shuffle")) {
            arr.shuffle();
        }
        if (!running) {
            if (rg.button(.{ .width = 120, .height = 30, .x = 730, .y = 10 }, "start")) {
                running = true;
                try modules.init(@intCast(algorithm), &arr);
                arr.resetCounters();
            }
        } else {
            rg.unlock();
            if (rg.button(.{ .width = 120, .height = 30, .x = 730, .y = 10 }, "stop")) {
                running = false;
            }
            rg.lock();
        }

        if (prev_running and !running) {
            modules.deinit(@intCast(algorithm));
            arr.resetColors();
        }
    }
}

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
