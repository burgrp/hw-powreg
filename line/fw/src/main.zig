const microzig = @import("microzig");

const Gate = @import("gate.zig");
const ZCD = @import("zcd.zig");
const Status = @import("status.zig");

//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;
const peripherals = microzig.chip.peripherals;

const STATUS_PIN = 2;
const GATE_PIN = 3;
const ZCD_PIN = 1;

const status = Status.at(peripherals.PORTA, STATUS_PIN);
const gate = Gate.at(peripherals.TCA0, peripherals.PORTA, GATE_PIN, status.gateStatus);
const zcd = ZCD.at(peripherals.AC0, peripherals.VREF, gate.zeroCross);

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn TCA0_LUNF() void {
            gate.handleInterruptTCA_OVF();
        }
        pub fn TCA0_CMP0() void {
            gate.handleInterruptTCA_CMP0();
        }
        pub fn TCA0_CMP1() void {
            gate.handleInterruptTCA_CMP1();
        }
        pub fn AC0_AC() callconv(.Interrupt) void {
            zcd.handleInterruptAC();
        }
    };
};

pub fn main() void {
    // CPU at 10MHz
    peripherals.CPU.CCP.write_raw(0xD8);
    peripherals.CLKCTRL.MCLKCTRLB.modify(.{ .PDIV = .{ .value = .@"2X" } });

    status.init();

    gate.init();
    gate.setDuty(0x10);

    zcd.init();

    microzig.cpu.enable_interrupts();

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });
    while (true) {
        asm volatile ("sleep");
    }
}
