const std = @import("std");

const avr = @import("deps/microzig-avr/build.zig");

const microzig = avr.microzig;

pub fn build(b: *std.build.Builder) !void {
    var exe = microzig.addEmbeddedExecutable(b, .{
        .name = "app",
        .source_file = .{
            .path = "src/main.zig",
        },
        .backing = .{
            .chip = avr.chips.attiny412,
        },
        .optimize = std.builtin.OptimizeMode.ReleaseSmall,
    });
    exe.installArtifact(b);
}
