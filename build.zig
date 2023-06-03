const std = @import("std");
const print = @import("std").debug.print;
const ArrayList = std.ArrayList;


pub fn build(b: *std.build.Builder) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const common_cflags: []const []const u8 = &.{
        "-fno-sanitize=undefined",
    };

    const lib = b.addStaticLibrary(.{
        .name = "argp",
        .target = target,
        .optimize = optimize,
    });

    const lib_sources = [_][]const u8{
        "argp-ba.c",
        "argp-eexst.c",
        "argp-fmtstream.c",
        "argp-help.c",
        "argp-parse.c",
        "argp-pv.c",
        "argp-pvh.c",
    };

    lib.addCSourceFiles(&lib_sources, common_cflags ++ [_][]const u8{
        "-DHAVE_UNISTD_H",
        "-DUNUSED="
    });
    lib.addIncludePath(".");
    lib.linkLibC();

    b.installFile("argp.h", "include/argp.h");
    b.installArtifact(lib);
}
