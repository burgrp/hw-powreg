const microzig = @import("microzig");

const Gate = @import("gate.zig");
const ZCD = @import("zcd.zig");

//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;
const peripherals = microzig.chip.peripherals;

const GATE_PIN = 3;
const ERR_PIN = 2;
const ZCD_PIN = 1;

const gate = Gate.at(microzig.chip.peripherals.TCA0, microzig.chip.peripherals.PORTA, GATE_PIN);
const zcd = ZCD.at(microzig.chip.peripherals.PORTA, ZCD_PIN, gate.zeroCross);

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn TCA0_LUNF() void {
            gate.handleTimerOVF();
        }
        pub fn TCA0_CMP0() void {
            gate.handleTimerCMP0();
        }
        pub fn TCA0_CMP1() void {
            gate.handleTimerCMP1();
        }
        pub fn PORTA_PORT() void {
            zcd.handlePort();
        }
    };
};

pub fn main() void {
    // CPU at 10MHz
    peripherals.CPU.CCP.write_raw(0xD8);
    peripherals.CLKCTRL.MCLKCTRLB.modify(.{ .PDIV = .{ .value = .@"2X" } });

    gate.init();
    gate.setDuty(50);

    zcd.init();

    peripherals.PORTA.DIRSET = (1 << ERR_PIN);

    // show error
    peripherals.PORTA.OUTSET = 1 << ERR_PIN;

    microzig.cpu.enable_interrupts();

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });
    while (true) {
        asm volatile ("sleep");
    }
}
