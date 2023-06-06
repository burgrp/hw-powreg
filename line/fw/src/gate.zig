const microzig = @import("microzig");

pub fn at(
    comptime timer: *volatile microzig.chip.types.peripherals.TCA,
    comptime port: *volatile microzig.chip.types.peripherals.PORT,
    comptime pin: u3,
    comptime statusCallback: *const fn (synced: bool) void,
) type {
    return struct {
        var duty: u8 = 0;
        var period: u16 = 0;

        // This assumes that the CPU is running at 10MHz.
        pub fn init() void {

            // timer at 2.5MHz, overflow at ~38Hz
            timer.SINGLE.INTCTRL.modify(.{ .OVF = 1, .CMP0 = 1 }); //, .CMP1 = 1 });
            timer.SINGLE.CTRLA.modify(.{ .ENABLE = 1, .CLKSEL = .{ .value = .DIV4 } });

            port.DIRSET = @as(u8, 1) << pin;

            updateStatus();
        }

        pub fn updateStatus() void {
            statusCallback(period > 0);
        }

        pub fn setDuty(new_duty: u8) void {
            duty = new_duty;
        }

        pub fn zeroCross() void {
            if (timer.SINGLE.CTRLA.read().ENABLE == 1) {
                timer.SINGLE.CTRLA.modify(.{ .ENABLE = 0 });
                period = (period + microzig.cpu.read_reg16(&timer.SINGLE.CNT)) >> 1;

                microzig.cpu.write_reg16(&timer.SINGLE.CNT, 0);

                const cmp = if (duty == 255) 0xFFFF else @truncate(u16, period / 256 * duty);
                microzig.cpu.write_reg16(&timer.SINGLE.CMP0, cmp);

                if (cmp > 0) {
                    port.OUTSET = 1 << pin;
                } else {
                    port.OUTCLR = 1 << pin;
                }
            }

            timer.SINGLE.CTRLA.modify(.{ .ENABLE = 1 });
            updateStatus();
        }

        pub fn handleInterruptTCA_OVF() void {
            timer.SINGLE.CTRLA.modify(.{ .ENABLE = 0 });
            period = 0;
            updateStatus();

            timer.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        }

        pub fn handleInterruptTCA_CMP0() void {
            port.OUTCLR = 1 << pin;
            timer.SINGLE.INTFLAGS.modify(.{ .CMP0 = 1 });
        }

        pub fn handleInterruptTCA_CMP1() void {
            timer.SINGLE.INTFLAGS.modify(.{ .CMP1 = 1 });
        }
    };
}
