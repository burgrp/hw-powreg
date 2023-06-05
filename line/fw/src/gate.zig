const microzig = @import("microzig");

// port: *volatile microzig.chip.types.peripherals.PORT,
// pin: u3,

pub fn create(comptime port: *volatile microzig.chip.types.peripherals.PORT, comptime pin: u3) type {
    return struct {
        const Self = @This();

        var duty: u8 = 0;

        pub fn init() void {
            port.DIRSET = @as(u8, 1) << pin;
        }

        pub fn setDuty(new_duty: u8) void {
            duty = new_duty;
        }
    };
}
