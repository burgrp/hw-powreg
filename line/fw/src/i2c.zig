const microzig = @import("microzig");
const std = @import("std");

pub fn at(
    comptime twi: *volatile microzig.chip.types.peripherals.TWI,
    comptime addrPort: *volatile microzig.chip.types.peripherals.PORT,
    comptime addrPin0: u3,
    comptime addrPinCount: u3,
) type {
    return struct {
        pub var rxBuffer: packed struct {
            power_duty: u8,
            fan_duty: u8,
            crc: u8,
        } = undefined;

        pub var txBuffer: packed struct {
            protocol: u8,
            status: packed struct {
                grid_sync: u1,
                rx_crc_error: u1,
                reserved: u6,
            },
            mosfet_temp1: u16,
            mosfet_temp2: u16,
            crc: u8,
        } = undefined;

        pub var watchDogFlag: bool = false;

        var rxPeriBuffer: [@sizeOf(@TypeOf(rxBuffer))]u8 = undefined;
        var txPeriBuffer: [@sizeOf(@TypeOf(txBuffer))]u8 = undefined;

        var cnt: u8 = 0;

        pub fn init(baseAddr: u7) void {
            inline for (0..addrPinCount) |i| {
                @field(addrPort, std.fmt.comptimePrint("PIN{}CTRL", .{addrPin0 + i})).modify(.{ .PULLUPEN = 1, .INVEN = 1 });
            }
            // Wait for pullup
            for (0..1000) |_| {
                asm volatile ("nop");
            }
            var addrMask: u8 = ((1 << addrPinCount) - 1) << addrPin0;
            var addr = baseAddr + ((addrPort.IN & addrMask) >> addrPin0);

            twi.SADDR = addr << 1;
            twi.SCTRLA.modify(.{ .DIEN = 1, .APIEN = 1, .SMEN = 1, .ENABLE = 1 });
            txBuffer.protocol = 1;
        }

        pub fn handleInterruptTWIS() void {
            const status = twi.SSTATUS.read();
            if (status.DIF == 1) {
                if (status.DIR == 1) {
                    if (cnt < txPeriBuffer.len) {
                        twi.SDATA = txPeriBuffer[cnt];
                    }
                } else {
                    if (cnt < rxPeriBuffer.len) {
                        rxPeriBuffer[cnt] = twi.SDATA;
                    }
                    if (cnt + 1 == rxPeriBuffer.len) {
                        var crc: u8 = 0;
                        for (rxPeriBuffer) |byte| {
                            crc ^= byte;
                        }
                        if (crc == 0xAA) {
                            rxBuffer = @bitCast(@TypeOf(rxBuffer), rxPeriBuffer);
                            txBuffer.status.rx_crc_error = 0;
                            watchDogFlag = true;
                        } else {
                            txBuffer.status.rx_crc_error = 1;
                        }
                    }
                }
                cnt += 1;
                twi.SSTATUS.modify(.{ .DIF = 1 });
            }
            if (status.APIF == 1) {
                cnt = 0;
                if (status.DIR == 1) {
                    txPeriBuffer = @bitCast(@TypeOf(txPeriBuffer), txBuffer);
                    var crc: u8 = 0xAA;
                    for (txPeriBuffer[0 .. txPeriBuffer.len - 1]) |byte| {
                        crc ^= byte;
                    }
                    txPeriBuffer[txPeriBuffer.len - 1] = crc;
                }
                twi.SSTATUS.modify(.{ .APIF = 1 });
            }
        }
    };
}
