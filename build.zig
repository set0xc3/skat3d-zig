const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tinycad = b.addExecutable(.{
        .name = "tinycad",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    tinycad.addIncludePath(.{ .path = "external/raylib/src" });
    tinycad.addLibraryPath(.{ .path = "external/raylib/build/raylib" });
    tinycad.linkSystemLibrary("raylib");
    tinycad.linkLibC();
    b.installArtifact(tinycad);

    // const sandbox = b.addExecutable(.{
    //     .name = "sandbox",
    //     .root_source_file = .{ .path = "sandbox/sandbox.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });
    // sandbox.linkLibrary(core);

    // b.installArtifact(sandbox);

    // const zopengl_pkg = zopengl.package(b, target, optimize, .{});
    // const zsdl_pkg = zsdl.package(b, target, optimize, .{});
    // zopengl_pkg.link(exe);
    // zsdl_pkg.link(exe);

    // --- Run command ---
    {
        const run_cmd = b.addRunArtifact(tinycad);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    // const unit_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });
    //
    // const run_unit_tests = b.addRunArtifact(unit_tests);
    //
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_unit_tests.step);
}
