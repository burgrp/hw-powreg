const microzig = @import("microzig");

pub fn at(comptime adc: *volatile microzig.chip.types.peripherals.ADC, comptime mosfetChannel1: u8, comptime mosfetChannel2: u8) type {
    return struct {
        pub var mosfet_temp: [2]u16 = undefined;

        pub fn init() void {
            adc.CTRLA.modify(.{ .RESSEL = .{ .value = .@"10BIT" } });
            adc.CTRLB.modify(.{ .SAMPNUM = .{ .value = .ACC1 } });
            adc.CTRLC.modify(.{ .REFSEL = .{ .value = .VDDREF }, .PRESC = .{ .value = .DIV8 } });
            adc.MUXPOS.write(.{ .MUXPOS = .{ .raw = mosfetChannel1 }, .padding = 0 });
            adc.INTCTRL.modify(.{ .RESRDY = 1 });
            adc.CTRLA.modify(.{ .ENABLE = 1 });

            adc.COMMAND.write(.{ .STCONV = 1, .padding = 0 });
        }

        pub fn handleInterruptADC_RESRDY() void {
            if (adc.INTFLAGS.read().RESRDY == 1) {
                var temp = microzig.cpu.read_reg16(&adc.RES);
                var channel = adc.MUXPOS.read().MUXPOS.raw;
                if (channel == mosfetChannel1) {
                    mosfet_temp[0] = temp;
                    adc.MUXPOS.write(.{ .MUXPOS = .{ .raw = mosfetChannel2 }, .padding = 0 });
                } else {
                    mosfet_temp[1] = temp;
                    adc.MUXPOS.write(.{ .MUXPOS = .{ .raw = mosfetChannel1 }, .padding = 0 });
                }

                adc.COMMAND.write(.{ .STCONV = 1, .padding = 0 });
                adc.INTFLAGS.modify(.{ .RESRDY = 1 });
            }
        }
    };
}
