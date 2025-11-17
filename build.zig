const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("raylib", raylib);
    exe_mod.addImport("raygui", raygui);

    if (target.query.os_tag == .emscripten) {
        const emsdk = rlz.emsdk;
        const wasm = b.addLibrary(.{
            .name = "zorting",
            .root_module = exe_mod,
        });
        const install_dir: std.Build.InstallDir = .{ .custom = "web" };

        var emcc_flags = emsdk.emccDefaultFlags(b.allocator, .{ .optimize = optimize });
        const optimiztion_flag = switch (optimize) {
            .Debug => "-Og",
            .ReleaseFast => "-Ofast",
            .ReleaseSmall => "-Os",
            else => "-O3",
        };
        try emcc_flags.put(optimiztion_flag, {});

        var emcc_settings = emsdk.emccDefaultSettings(b.allocator, .{ .optimize = optimize });
        try emcc_settings.put("USE_OFFSET_CONVERTER", "1");
        try emcc_settings.put("ALLOW_MEMORY_GROWTH", "1");
        try emcc_settings.put("MALLOC", "emmalloc");
        try emcc_settings.put("FULL-ES3", "1");
        try emcc_settings.put("USE_GLFW", "3");
        //try emcc_settings.put("EVAL_CTORS", "1");
        try emcc_settings.put("STACK_SIZE", "256kb");

        const emcc_step = emsdk.emccStep(b, raylib_artifact, wasm, .{
            .optimize = optimize,
            .flags = emcc_flags,
            .settings = emcc_settings,
            .install_dir = install_dir,
            .embed_paths = &.{.{ .src_path = "resources/" }},
            .shell_file_path = .{
                .src_path = .{
                    .owner = b,
                    .sub_path = "src/shell.html",
                },
            },
        });
        b.getInstallStep().dependOn(emcc_step);
    } else {
        const exe = b.addExecutable(.{
            .name = "zorting",
            .root_module = exe_mod,
        });
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step("run", "Run zorting");
        run_step.dependOn(&run_cmd.step);
    }
}
