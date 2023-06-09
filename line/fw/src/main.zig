const microzig = @import("microzig");

const Gate = @import("gate.zig");
const ZCD = @import("zcd.zig");
const Status = @import("status.zig");
const I2C = @import("i2c.zig");

//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;
const peripherals = microzig.chip.peripherals;

const STATUS_PIN = 6;
const GATE_PIN = 3;

const gate = Gate.at(peripherals.TCA0, peripherals.PORTA, GATE_PIN);
const zcd = ZCD.at(peripherals.AC0, peripherals.VREF, gate.zeroCross);
const status = Status.at(peripherals.PORTA, STATUS_PIN, peripherals.RTC);
const i2c = I2C.at(peripherals.TWI0);

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn TCA0_LUNF() void {
            gate.handleInterruptTCA_OVF();
        }
        pub fn TCA0_CMP0() void {
            gate.handleInterruptTCA_CMP0();
        }
        pub fn AC0_AC() void {
            zcd.handleInterruptAC();
        }
        pub fn RTC_PIT() void {
            status.handleInterruptRTC_PIT();
        }
        pub fn TWI0_TWIS() void {
            i2c.handleInterruptTWIS();
        }
    };
};

pub fn update() void {
    status.setDuty(gate.getDuty());
    status.setSynchronized(gate.isSynchronized());
}

pub fn main() void {
    // CPU at 10MHz
    peripherals.CPU.CCP.write_raw(0xD8);
    peripherals.CLKCTRL.MCLKCTRLB.modify(.{ .PDIV = .{ .value = .@"2X" } });

    status.init();

    gate.init();
    gate.setDuty(128);

    zcd.init();
    i2c.init(50);

    microzig.cpu.enable_interrupts();

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });
    while (true) {
        asm volatile ("sleep");
        update();
    }
}
