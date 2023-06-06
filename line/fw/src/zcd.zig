const microzig = @import("microzig");
const std = @import("std");

pub fn at(comptime port: *volatile microzig.chip.types.peripherals.PORT, comptime pin: u3, comptime zeroCrossHandler: *const fn () void) type {
    return struct {
        pub fn init() void {
            @field(port, std.fmt.comptimePrint("PIN{}CTRL", .{pin})).modify(.{ .PULLUPEN = 0, .ISC = .{ .value = .BOTHEDGES } });
        }

        pub fn handlePort() void {
            if ((port.INTFLAGS.read().INT & (1 << pin)) != 0) {
                zeroCrossHandler();
                port.INTFLAGS.write(.{ .INT = 1 << pin });
            }
        }
    };
}
