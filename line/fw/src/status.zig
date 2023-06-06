const microzig = @import("microzig");

pub fn at(comptime port: *volatile microzig.chip.types.peripherals.PORT, comptime pin: u3) type {
    return struct {
        pub fn init() void {
            port.DIRSET = 1 << pin;
        }

        pub fn gateStatus(synced: bool) void {
            if (synced) {
                port.OUTCLR = 1 << pin;
            } else {
                port.OUTSET = 1 << pin;
            }
        }
    };
}
