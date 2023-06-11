const microzig = @import("microzig");

const WatchDog = @import("watchdog.zig");
const Gate = @import("gate.zig");
const ZCD = @import("zcd.zig");
const Status = @import("status.zig");
const I2C = @import("i2c.zig");
const TempSense = @import("tempsense.zig");
const Fan = @import("fan.zig");

const peripherals = microzig.chip.peripherals;

const watchDog = WatchDog.at(peripherals.WDT);
const gate = Gate.at(peripherals.TCA0, peripherals.PORTB, 2);
const zcd = ZCD.at(peripherals.AC0, peripherals.VREF, gate.zeroCross);
const status = Status.at(peripherals.PORTB, 3, peripherals.RTC);
const i2c = I2C.at(peripherals.TWI0, peripherals.PORTA, 1, 3);
const tempSense = TempSense.at(peripherals.ADC0, 4, 6);
const fan = Fan.at(peripherals.TCB0);

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
        pub fn ADC0_RESRDY() void {
            tempSense.handleInterruptADC_RESRDY();
        }
    };
};

pub fn update() void {
    gate.duty = i2c.rxBuffer.power_duty;
    status.duty = i2c.rxBuffer.power_duty;
    fan.setDuty(i2c.rxBuffer.fan_duty);

    var synchronized = gate.isSynchronized();
    status.synchronized = synchronized;
    i2c.txBuffer.status.grid_sync = if (synchronized) 1 else 0;

    i2c.txBuffer.mosfet_temp1 = tempSense.mosfet_temp[0];
    i2c.txBuffer.mosfet_temp2 = tempSense.mosfet_temp[1];

    if (i2c.watchDogFlag) {
        watchDog.reset();
        i2c.watchDogFlag = false;
    }
}

pub fn main() void {
    // CPU at 10MHz
    peripherals.CPU.CCP.write_raw(0xD8);
    peripherals.CLKCTRL.MCLKCTRLB.modify(.{ .PDIV = .{ .value = .@"2X" } });

    watchDog.init();
    status.init();
    gate.init();
    zcd.init();
    i2c.init(50);
    tempSense.init();
    fan.init();

    microzig.cpu.enable_interrupts();

    peripherals.SLPCTRL.CTRLA.modify(.{ .SMODE = .{ .value = .IDLE }, .SEN = 1 });
    while (true) {
        asm volatile ("sleep");
        update();
    }
}
