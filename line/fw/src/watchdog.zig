const microzig = @import("microzig");

pub fn at(
    comptime wdt: *volatile microzig.chip.types.peripherals.WDT,
) type {
    return struct {
        pub fn init() void {
            microzig.chip.peripherals.CPU.CCP.write_raw(0xD8);
            wdt.CTRLA.modify(.{ .PERIOD = .{ .value = .@"8KCLK" } });
        }

        pub fn reset() void {
            asm volatile ("wdr");
        }
    };
}
