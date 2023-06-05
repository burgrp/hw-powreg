const microzig = @import("microzig");

port: *volatile microzig.chip.types.peripherals.PORT = undefined,
pin: u3 = undefined,

duty: u8 = 0,

const Self = @This();

pub fn init(self: *Self) void {
    self.port.DIRSET = @as(u8, 1) << self.pin;
}

pub fn setDuty(self: *Self, new_duty: u8) void {
    self.duty = new_duty;
}
