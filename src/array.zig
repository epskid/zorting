const max_array_capacity: usize = 2000;

var prng = std.Random.DefaultPrng.init(4); // chosen by fair dice roll; guaranteed to be random (https://xkcd.com/221/)

pub const Array = struct {
    const Self = @This();

    colors: [max_array_capacity]rl.Color,
    inner: [max_array_capacity]u32,
    len: usize,

    comparisons: usize,
    accesses: usize,

    pub fn init(len: usize) Self {
        var self: Self = undefined;
        self.len = len;
        self.resetColors();
        self.resetCounters();

        return self;
    }

    pub fn resetColors(self: *Self) void {
        @memset(&self.colors, .white);
    }

    pub fn resetCounters(self: *Self) void {
        self.accesses = 0;
        self.comparisons = 0;
    }

    pub fn draw(self: *Self) void {
        const height_scale = @as(f32, @floatFromInt(rl.getScreenHeight())) / @as(f32, @floatFromInt(self.len));
        const width_scale = @as(f32, @floatFromInt(rl.getScreenWidth())) / @as(f32, @floatFromInt(self.len));
        for (0.., self.inner[0..self.len]) |i, elem| {
            var x: f32 = @floatFromInt(i);
            x *= width_scale;

            var unscaled_height: f32 = @floatFromInt(elem);
            unscaled_height *= height_scale;
            const height: i32 = @intFromFloat(unscaled_height);

            rl.drawRectangle(@intFromFloat(x), rl.getScreenHeight() - height, @intFromFloat(@ceil(width_scale)), height, self.colors[i]);
        }

        rl.drawText(rl.textFormat("comparisons: %i\narray accesses: %i\n(hover for options)", .{ self.comparisons, self.accesses }), 10, 10, 16, .gray);
    }

    pub fn shuffle(self: *Self) void {
        const random = prng.random();
        random.shuffle(u32, self.inner[0..self.len]);
    }

    pub fn ascending(self: *Self) void {
        for (0..self.len) |i| {
            self.inner[i] = @intCast(i + 1);
        }
    }

    pub fn get(self: *Self, idx: usize) u32 {
        if (idx >= self.len) {
            std.builtin.panic.outOfBounds(idx, self.len);
        }

        self.accesses += 1;
        self.colors[idx] = .red;
        return self.inner[idx];
    }

    pub fn set(self: *Self, idx: usize, value: u32) void {
        if (idx >= self.len) {
            std.builtin.panic.outOfBounds(idx, self.len);
        }

        self.accesses += 1;
        self.colors[idx] = .red;
        self.inner[idx] = value;
    }

    pub fn swap(self: *Self, idx1: usize, idx2: usize) void {
        self.colors[idx1] = .red;
        self.colors[idx2] = .red;

        const tmp = self.inner[idx1];
        self.inner[idx1] = self.inner[idx2];
        self.inner[idx2] = tmp;
    }
};

const std = @import("std");
const rl = @import("raylib");
