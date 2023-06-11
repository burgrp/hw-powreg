const microzig = @import("microzig");
const std = @import("std");

const protocol_version = 1;

pub fn at(
    comptime twi: *volatile microzig.chip.types.peripherals.TWI,
) type {
    return struct {
        pub var rxBuffer: packed struct {
            duty: u8,
            crc: u8,
        } = undefined;

        pub var txBuffer: packed struct {
            protocol: u8 = protocol_version,
            status: packed struct {
                grid_sync: u1,
                rx_crc_error: u1,
                reserved: u6,
            },
            chip_temp: u16,
            crc: u8,
        } = undefined;

        var rxPeriBuffer: [@sizeOf(@TypeOf(rxBuffer))]u8 = undefined;
        var txPeriBuffer: [@sizeOf(@TypeOf(txBuffer))]u8 = undefined;

        var cnt: u8 = 0;

        pub fn init(addr: u7) void {
            twi.SADDR = addr << 1;
            twi.SCTRLA.modify(.{ .DIEN = 1, .APIEN = 1, .SMEN = 1, .ENABLE = 1 });
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
