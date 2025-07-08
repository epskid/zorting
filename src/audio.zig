const array = @import("array.zig");

pub const AudioManager = struct {
    const Self = @This();

    sound: rl.Sound,
    range: [array.max_capacity]rl.Sound,

    pub fn init() !Self {
        var self: Self = .{
            .sound = try rl.loadSound("resources/blip.wav"),
            .range = undefined,
        };
        for (&self.range, 0..) |*snd, i| {
            snd.* = rl.loadSoundAlias(self.sound);
            rl.setSoundPitch(snd.*, 1.2 + @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(array.max_capacity)));
        }

        return self;
    }

    pub fn deinit(self: *Self) void {
        for (self.range) |alias| {
            rl.unloadSoundAlias(alias);
        }

        rl.unloadSound(self.sound);
    }

    pub inline fn playIndex(self: *Self, index: usize, max: usize) void {
        rl.playSound(self.range[(index * array.max_capacity) / max]);
    }
};

const rl = @import("raylib");
const std = @import("std");
