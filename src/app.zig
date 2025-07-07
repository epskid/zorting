const array = @import("array.zig");
const modules = @import("modules/modules.zig");

const ui_width = 645;
const ui_height = 90;

pub const App = struct {
    const Self = @This();

    algorithm: i32,
    sorting: bool,
    arr: array.Array,
    delay_microseconds: f32,
    step_timer: std.time.Timer,

    pub fn init() !Self {
        return .{
            .algorithm = 0,
            .sorting = false,
            .arr = try array.Array.init(10),
            .delay_microseconds = 1,
            .step_timer = try std.time.Timer.start(),
        };
    }

    pub fn deinit(self: *Self) void {
        self.arr.deinit();
    }

    pub fn updateEmscripten(self_opaque: ?*anyopaque) callconv(.C) void {
        var self = @as(*Self, @ptrCast(@alignCast(self_opaque.?)));
        self.update() catch {};
    }

    pub fn update(self: *Self) !void {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        if (self.sorting and self.timeToStep()) {
            self.stepSortingAlgorithm();
            self.step_timer.reset();
        }

        self.arr.draw();

        if (self.shouldUpdateUi()) {
            if (self.sorting) {
                rg.disable();
            } else {
                rg.enable();
            }

            rl.drawRectangle(0, 0, ui_width, ui_height, .dark_gray);
            self.drawArrayStats();
            self.updateAlgorithmTypeDropdown();
            self.updateDelaySlider();
            self.updateArraySizeSlider();
            self.updateShuffleButton();
            try self.updateStartStopButtons();
        }
    }

    inline fn timeToStep(self: *Self) bool {
        const timer_microseconds = @divTrunc(self.step_timer.read(), 1000);
        const delay_microseconds: u64 = @intFromFloat(self.delay_microseconds);

        return timer_microseconds >= delay_microseconds;
    }

    inline fn stepSortingAlgorithm(self: *Self) void {
        self.arr.resetColors();
        const done = modules.step(&self.arr);
        if (done) {
            self.sorting = false;
        }
    }

    inline fn shouldUpdateUi(self: *const Self) bool {
        return !self.sorting or (rl.getMouseX() < ui_width and rl.getMouseY() < ui_height);
    }

    inline fn usableWhileSorting(self: *const Self) void {
        if (self.sorting) rg.enable();
    }

    inline fn endUsableWhileSorting(self: *const Self) void {
        if (self.sorting) rg.disable();
    }

    inline fn drawArrayStats(self: *const Self) void {
        const text = rl.textFormat("comparisons: %i\naccesses: %i", .{ self.arr.comparisons, self.arr.accesses });
        rl.drawText(text, 10, 50, 14, .white);
    }

    inline fn updateDelaySlider(self: *Self) void {
        self.usableWhileSorting();
        defer self.endUsableWhileSorting();

        const bounds: rl.Rectangle = .{
            .x = 190,
            .y = 50,
            .width = 270,
            .height = 30,
        };
        const delay_display = rl.textFormat("%i", .{@as(i32, @intFromFloat(self.delay_microseconds))});
        _ = rg.sliderBar(bounds, "delay", delay_display, &self.delay_microseconds, 0, 100000);
    }

    fn updateAlgorithmTypeDropdown(self: *Self) void {
        const static = struct {
            var editing = false;
        };

        const bounds: rl.Rectangle = .{
            .x = 10,
            .y = 10,
            .width = 135,
            .height = 30,
        };
        if (rg.dropdownBox(bounds, modules.selection_string, &self.algorithm, static.editing) != 0) {
            static.editing = !static.editing;
        }
    }

    fn updateArraySizeSlider(self: *Self) void {
        const static = struct {
            var sizeInput: f32 = 1;
        };

        const bounds: rl.Rectangle = .{
            .x = 190,
            .y = 10,
            .width = 270,
            .height = 30,
        };
        if (rg.sliderBar(bounds, "size", rl.textFormat("%i", .{self.arr.len}), &static.sizeInput, 1, @as(f32, @floatFromInt(array.max_capacity)) / 10) != 0) {
            self.arr.len = @intFromFloat(static.sizeInput);
            self.arr.len *= 10;

            self.arr.ascending();
            self.arr.resetColors();
        }
    }

    inline fn updateShuffleButton(self: *Self) void {
        const bounds: rl.Rectangle = .{
            .x = 515,
            .y = 10,
            .width = 120,
            .height = 30,
        };
        if (rg.button(bounds, "shuffle")) {
            self.arr.shuffle();
            self.arr.resetColors();
        }
    }

    inline fn updateStartButton(self: *Self) !void {
        const bounds: rl.Rectangle = .{
            .x = 515,
            .y = 50,
            .width = 120,
            .height = 30,
        };
        if (rg.button(bounds, "start")) {
            self.sorting = true;
            try modules.init(self.algorithm, &self.arr);
            self.arr.resetCounters();
        }
    }

    inline fn updateStopButton(self: *Self) void {
        self.usableWhileSorting();
        defer self.endUsableWhileSorting();

        const bounds: rl.Rectangle = .{
            .x = 515,
            .y = 50,
            .width = 120,
            .height = 30,
        };
        if (rg.button(bounds, "stop")) {
            self.sorting = false;
            modules.deinit();
        }
    }

    inline fn updateStartStopButtons(self: *Self) !void {
        if (self.sorting) {
            self.updateStopButton();
        } else {
            try self.updateStartButton();
        }
    }
};

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
