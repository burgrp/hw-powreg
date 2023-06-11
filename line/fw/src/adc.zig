const microzig = @import("microzig");

pub fn at(
    comptime adc: *volatile microzig.chip.types.peripherals.ADC,
) type {
    return struct {
        pub fn init() void {
            adc.CTRLA.modify(.{ .RESSEL = .{ .value = .@"10BIT" } });
        }
        pub fn handleInterruptADC_RESRDY() void {}
    };
}
