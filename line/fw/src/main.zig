const micro = @import("microzig");

//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;
const peripherals = micro.chip.peripherals;

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn TCA0_LUNF() void {
            peripherals.PORTA.OUTTGL = 1 << 3;
            peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        }
    };
};

pub fn main() void {
    peripherals.PORTA.DIR = (1 << 3) | (1 << 2);

    peripherals.TCA0.SINGLE.CTRLA.modify(.{ .ENABLE = 1, .CLKSEL = .{ .value = .DIV16 } });
    peripherals.TCA0.SINGLE.INTCTRL.modify(.{ .OVF = 1 });

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });

    micro.cpu.enable_interrupts();

    while (true) {
        asm volatile ("sleep");
    }
}
