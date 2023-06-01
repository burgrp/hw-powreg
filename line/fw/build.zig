const std = @import("std");

const microzig = @import("deps/microzig/build.zig");
const chips = @import("src/avr/chips.zig");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    var exe = microzig.addEmbeddedExecutable(b, .{
        .name = "app",
        .source_file = .{
            .path = "src/main.zig",
        },
        .backing = .{
            .chip = chips.attiny412,
        },
        .optimize = optimize,
    });
    exe.installArtifact(b);
}
