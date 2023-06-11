const microzig = @import("microzig");

pub fn at(
    comptime adc: *volatile microzig.chip.types.peripherals.ADC,
) type {
    return struct {
        pub var chip_temp: u16 = 0;

        pub fn init() void {
            adc.CTRLA.modify(.{ .RESSEL = .{ .value = .@"8BIT" }, .FREERUN = 1 });
            adc.CTRLB.modify(.{ .SAMPNUM = .{ .value = .ACC1 } });
            adc.CTRLC.modify(.{ .REFSEL = .{ .value = .INTREF } });
            adc.MUXPOS.modify(.{ .MUXPOS = .{ .value = .TEMPSENSE } });
            adc.INTCTRL.modify(.{ .RESRDY = 1 });
            adc.CTRLA.modify(.{ .ENABLE = 1 });

            adc.COMMAND.write(.{ .STCONV = 1, .padding = 0 });
        }

        pub fn handleInterruptADC_RESRDY() void {
            if (adc.INTFLAGS.read().RESRDY == 1) {
                chip_temp = microzig.cpu.read_reg16(&adc.RES);
                adc.INTFLAGS.modify(.{ .RESRDY = 1 });
            }
        }
    };
}
