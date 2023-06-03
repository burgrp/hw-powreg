const micro = @import("microzig");

//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;
const peripherals = micro.chip.peripherals;

pub const microzig_options = struct {
    pub const interrupts = struct {

        //peripherals.PORTA.OUTTGL = 1 << 3;
        // peripherals.PORTA.OUTCLR = 1 << 3;
        // peripherals.RTC.PITINTFLAGS.write(.{ .PI = 1, .padding = 0 });

        pub fn TCA0_LUNF() void {
            peripherals.PORTA.OUTTGL = 1 << 3;
            peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        }
    };
};

pub fn main() void {
    peripherals.PORTA.DIR = (1 << 3) | (1 << 2);

    peripherals.CPU.CCP.write(.{ .CCP = .{ .value = .IOREG } });
    peripherals.CPUINT.CTRLA.modify(.{ .CVT = 1, .IVSEL = 1 });

    peripherals.TCA0.SINGLE.CTRLA.modify(.{ .ENABLE = 1, .CLKSEL = .{ .value = .DIV16 } });
    peripherals.TCA0.SINGLE.INTCTRL.modify(.{ .OVF = 1 });

    micro.cpu.enable_interrupts();

    while (true) {
        // if (peripherals.TCA0.SINGLE.INTFLAGS.read().OVF == 1) {
        //     peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        //     peripherals.PORTA.OUTTGL = 1 << 2;
        // }
    }
}
