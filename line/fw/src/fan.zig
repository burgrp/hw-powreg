const microzig = @import("microzig");

pub fn at(comptime timer: *volatile microzig.chip.types.peripherals.TCB) type {
    return struct {
        pub fn init() void {
            setDuty(0);
            timer.CTRLB.modify(.{ .CCMPEN = 1, .CNTMODE = .{ .value = .PWM8 } });
            timer.CTRLA.modify(.{ .ENABLE = 1,  });
        }

        pub fn setDuty(duty: u8) void {
            microzig.cpu.write_reg16(&timer.CCMP, @as(u16, duty) << 8 | 0xFE);
        }
    };
}
