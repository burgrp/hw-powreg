const std = @import("std");
const micro = @import("../deps/microzig/build.zig");
const Chip = micro.Chip;
const MemoryRegion = micro.MemoryRegion;

// Generated file, do not edit.

fn root_dir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

pub const attiny412 = Chip.from_standard_paths(root_dir(), .{
    .name = "ATtiny412",
    .cpu = micro.cpus.avr5,
    .memory_regions = &.{
        MemoryRegion{ .offset = 0x00000000, .length = 0x1000, .kind = .flash },
        MemoryRegion{ .offset = 0x3f00, .length = 0x0100, .kind = .ram },
    },
});

pub const attiny414 = Chip.from_standard_paths(root_dir(), .{
    .name = "ATtiny414",
    .cpu = micro.cpus.avr5,
    .memory_regions = &.{
        MemoryRegion{ .offset = 0x00000000, .length = 0x1000, .kind = .flash },
        MemoryRegion{ .offset = 0x3f00, .length = 0x0100, .kind = .ram },
    },
});
