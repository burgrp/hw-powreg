const micro = @import("microzig");

pub fn main() void {
    // blink
    micro.chip.peripherals.PORTA.DIR = 1 << 3;
    while (true) {
        micro.chip.peripherals.PORTA.OUT = 1 << 3;
        busyloop();
        micro.chip.peripherals.PORTA.OUT = 0;
        busyloop();
    }
}

fn busyloop() void {
    const limit = 100_000;

    var i: u24 = 0;
    while (i < limit) : (i += 1) {
        micro.chip.peripherals.PORTA.OUTSET = 1 << 2;
    }
}
