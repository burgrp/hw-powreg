const microzig = @import("microzig");
const std = @import("std");

pub fn at(comptime comparator: *volatile microzig.chip.types.peripherals.AC, comptime vref: *volatile microzig.chip.types.peripherals.VREF, comptime zeroCrossHandler: *const fn () void) type {
    return struct {
        pub fn init() void {
            vref.CTRLA.modify(.{
                .DAC0REFSEL = .{ .value = .@"1V5" },
            });
            vref.CTRLB.modify(.{
                .DAC0REFEN = 1,
            });
            comparator.MUXCTRLA.modify(.{
                .MUXNEG = .{ .value = .VREF },
            });
            comparator.INTCTRL.modify(.{
                .CMP = 1,
            });
            comparator.CTRLA.modify(.{
                .ENABLE = 1,
                .HYSMODE = .{ .value = .@"50mV" },
                .INTMODE = .{ .value = .BOTHEDGE },
            });
        }

        pub fn handleInterruptAC() void {
            if (comparator.STATUS.read().CMP == 1) {
                zeroCrossHandler();
                comparator.STATUS.modify(.{ .CMP = 1 });
            }
        }
    };
}
