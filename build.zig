const std = @import("std");
const print = @import("std").debug.print;

pub fn build(b: *std.build.Builder) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    flags.appendSlice(&.{
        "-DHAVE_UNISTD_H",
        "-DUNUSED="
    }) catch |err| {
        std.log.err("Error appending iterable dir: {}", .{err});
        std.os.exit(1);
    };

    if (target.isDarwin()) {
        flags.appendSlice(&.{
            "-DHAVE_DECL_FPUTS_UNLOCKED=0",
            "-DHAVE_DECL_FWRITE_UNLOCKED=0",
            "-DHAVE_DECL_PROGRAM_INVOCATION_NAME=0",
        }) catch |err| {
            std.log.err("Error appending iterable dir: {}", .{err});
            std.os.exit(1);
        };
    }

    const lib = b.addStaticLibrary(.{
        .name = "argp",
        .target = target,
        .optimize = optimize,
    });

    lib.addCSourceFiles(.{
        .files = &.{
            "argp-ba.c",
            "argp-eexst.c",
            "argp-fmtstream.c",
            "argp-help.c",
            "argp-parse.c",
            "argp-pv.c",
            "argp-pvh.c",
        },
        .flags = flags.items
    });

    if (target.isDarwin()) {
        lib.addCSourceFiles(.{
            .files = &.{
                "strchrnul.c",
            },
            .flags = flags.items
        });
    }

    lib.addIncludePath(.{ .path = "." });
    lib.linkLibC();

    b.installFile("argp.h", "include/argp.h");
    b.installArtifact(lib);
}
