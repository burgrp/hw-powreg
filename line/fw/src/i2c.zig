const microzig = @import("microzig");

pub fn at(
    comptime twi: *volatile microzig.chip.types.peripherals.TWI,
) type {
    return struct {
        var buffer: [2]u8 = undefined;

        pub fn init(addr: u7) void {
            twi.SADDR = addr << 1;
            twi.SCTRLA.modify(.{ .DIEN = 1, .APIEN = 1, .SMEN = 1, .ENABLE = 1 });
        }

        pub fn handleInterruptTWIS() void {
            const status = twi.SSTATUS.read();
            if (status.DIF == 1) {
                twi.SDATA = twi.SDATA + 1;
                twi.SSTATUS.modify(.{ .DIF = 1 });
            }
            if (status.APIF == 1) {
                twi.SSTATUS.modify(.{ .APIF = 1 });
            }
        }
    };
}
