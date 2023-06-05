const microzig = @import("microzig");

const gate = @import("gate.zig");

//const peripherals = @import("../deps/microzig-avr/src/chips/ATtiny412.zig").devices.ATtiny412.peripherals;
const peripherals = microzig.chip.peripherals;

const GATE_PIN = 3;
const ERR_PIN = 2;
const ZCD_PIN = 1;

// var gate = Gate{
//     .port = microzig.chip.peripherals.PORTA,
//     .pin = GATE_PIN,
// };

var period: u16 = 0;

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn TCA0_LUNF() void {
            // gate off
            peripherals.PORTA.OUTCLR = 1 << GATE_PIN;
            // stop timer
            peripherals.TCA0.SINGLE.CTRLA.modify(.{ .ENABLE = 0 });
            // show error
            peripherals.PORTA.OUTSET = 1 << ERR_PIN;
            // clear interrupt flag
            peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .OVF = 1 });
        }
        pub fn TCA0_CMP0() void {
            // gate on
            peripherals.PORTA.OUTSET = 1 << GATE_PIN;
            // clear interrupt flag
            peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .CMP0 = 1 });
        }
        pub fn TCA0_CMP1() void {
            // gate off
            peripherals.PORTA.OUTCLR = 1 << GATE_PIN;
            // clear interrupt flag
            peripherals.TCA0.SINGLE.INTFLAGS.modify(.{ .CMP1 = 1 });
        }
        pub fn PORTA_PORT() void {

            // if timer is running, measure period
            if (peripherals.TCA0.SINGLE.CTRLA.read().ENABLE == 1) {
                period = peripherals.TCA0.SINGLE.CNT;

                //peripherals.PORTA.OUTSET = 1 << GATE_PIN;
                peripherals.TCA0.SINGLE.CMP0 = 1000; //period / 16;
                peripherals.TCA0.SINGLE.CMP1 = period / 4;
            }

            // start timer from zero
            peripherals.TCA0.SINGLE.CNT = 0;
            peripherals.TCA0.SINGLE.CTRLA.modify(.{ .ENABLE = 1 });

            // clear error
            peripherals.PORTA.OUTCLR = 1 << ERR_PIN;

            // clear interrupt flag
            peripherals.PORTA.INTFLAGS.write(.{ .INT = 1 << ZCD_PIN });
        }
    };
};

pub fn main() void {
    const g = gate.create(microzig.chip.peripherals.PORTA, GATE_PIN);
    g.init();
    g.setDuty(50);

    peripherals.PORTA.DIRSET = (1 << ERR_PIN);
    peripherals.PORTA.PIN1CTRL.modify(.{ .PULLUPEN = 0, .ISC = .{ .value = .BOTHEDGES } });

    // CPU at 10MHz
    peripherals.CPU.CCP.write_raw(0xD8);
    peripherals.CLKCTRL.MCLKCTRLB.modify(.{ .PDIV = .{ .value = .@"2X" } });

    // TCA0 at 2.5MHz, overflow at ~38Hz
    peripherals.TCA0.SINGLE.CTRLA.modify(.{ .ENABLE = 0, .CLKSEL = .{ .value = .DIV4 } });
    peripherals.TCA0.SINGLE.INTCTRL.modify(.{ .OVF = 1, .CMP0 = 1, .CMP1 = 1 });

    // show error
    peripherals.PORTA.OUTSET = 1 << ERR_PIN;

    microzig.cpu.enable_interrupts();

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });
    while (true) {
        asm volatile ("sleep");
    }
}
