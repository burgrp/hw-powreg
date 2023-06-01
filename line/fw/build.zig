const std = @import("std");

const microzig = @import("deps/microzig/build.zig");
const avr = @import("src/avr.zig");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    var exe = microzig.addEmbeddedExecutable(b, .{
        .name = "my-executable",
        .source_file = .{
            .path = "src/main.zig",
        },
        .backing = .{
            // .board = atmega.boards.arduino_nano,
            .chip = avr.chips.attiny412,
        },
        .optimize = optimize,
    });
    exe.installArtifact(b);
}
