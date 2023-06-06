const microzig = @import("microzig");

pub fn at(comptime timer: *volatile microzig.chip.types.peripherals.TCA, comptime port: *volatile microzig.chip.types.peripherals.PORT, comptime pin: u3) type {
    return struct {
        var duty: u8 = 0;

        // This assumes that the CPU is running at 10MHz.
        pub fn init() void {

            // timer at 2.5MHz, overflow at ~38Hz
            timer.SINGLE.CTRLA.modify(.{ .ENABLE = 0, .CLKSEL = .{ .value = .DIV4 } });
            timer.SINGLE.INTCTRL.modify(.{ .OVF = 1, .CMP0 = 1, .CMP1 = 1 });

            port.DIRSET = @as(u8, 1) << pin;
        }

        pub fn setDuty(new_duty: u8) void {
            duty = new_duty;
        }

        pub fn zeroCross() void {
            // // clear error
            // port.OUTCLR = 1 << ERR_PIN;

            // if timer is running, measure period
            if (timer.SINGLE.CTRLA.read().ENABLE == 1) {
                var period = timer.SINGLE.CNT;

                //port.OUTSET = 1 << GATE_PIN;
                timer.SINGLE.CMP0 = 1000; //period / 16;
                timer.SINGLE.CMP1 = period / 4;
            }

            // start timer from zero
            timer.SINGLE.CNT = 0;
            timer.SINGLE.CTRLA.modify(.{ .ENABLE = 1 });
        }

        pub fn handleTimerOVF() void {
            // gate off
            port.OUTCLR = 1 << pin;
            // stop timer
            timer.SINGLE.CTRLA.modify(.{ .ENABLE = 0 });
            // show error
            // port.OUTSET = 1 << ERR_PIN;
            // clear interrupt flag
            timer.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        }

        pub fn handleTimerCMP0() void {
            // gate on
            port.OUTSET = 1 << pin;
            // clear interrupt flag
            timer.SINGLE.INTFLAGS.modify(.{ .CMP0 = 1 });
        }

        pub fn handleTimerCMP1() void {
            // gate off
            port.OUTCLR = 1 << pin;
            // clear interrupt flag
            timer.SINGLE.INTFLAGS.modify(.{ .CMP1 = 1 });
        }
    };
}
