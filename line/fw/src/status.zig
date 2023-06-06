const microzig = @import("microzig");

pub fn at(comptime port: *volatile microzig.chip.types.peripherals.PORT, comptime pin: u3, comptime rtc: *volatile microzig.chip.types.peripherals.RTC) type {
    return struct {
        var duty: u8 = 0;
        var synchronized: bool = false;

        pub fn init() void {
            port.DIRSET = 1 << pin;

            rtc.CLKSEL.modify(.{ .CLKSEL = .{ .value = .INT32K } });
            rtc.PITCTRLA.modify(.{ .PITEN = 1, .PERIOD = .{ .value = .CYC8192 } });
            rtc.PITINTCTRL.modify(.{ .PI = 1 });
        }

        pub fn setDuty(new_duty: u8) void {
            duty = new_duty;
        }

        pub fn setSynchronized(new_synchronized: bool) void {
            synchronized = new_synchronized;
        }

        pub fn handleInterruptRTC_PIT() void {
            if (!synchronized) {
                port.OUTTGL = 1 << pin;
            } else {
                if (duty > 0) {
                    port.OUTSET = 1 << pin;
                } else {
                    port.OUTCLR = 1 << pin;
                }
            }
            rtc.PITINTFLAGS.modify(.{ .PI = 1 });
        }
    };
}
