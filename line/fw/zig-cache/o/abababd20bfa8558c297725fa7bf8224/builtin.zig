const std = @import("std");
/// Zig version. When writing code that supports multiple versions of Zig, prefer
/// feature detection (i.e. with `@hasDecl` or `@hasField`) over version checks.
pub const zig_version = std.SemanticVersion.parse(zig_version_string) catch unreachable;
pub const zig_version_string = "0.11.0-dev.3045+526065723";
pub const zig_backend = std.builtin.CompilerBackend.stage2_llvm;

pub const output_mode = std.builtin.OutputMode.Exe;
pub const link_mode = std.builtin.LinkMode.Static;
pub const is_test = false;
pub const single_threaded = true;
pub const abi = std.Target.Abi.eabi;
pub const cpu: std.Target.Cpu = .{
    .arch = .avr,
    .model = &std.Target.avr.cpu.avr5,
    .features = std.Target.avr.featureSet(&[_]std.Target.avr.Feature{
        .addsubiw,
        .avr0,
        .avr1,
        .avr2,
        .avr3,
        .avr5,
        .@"break",
        .ijmpcall,
        .jmpcall,
        .lpm,
        .lpmx,
        .memmappedregs,
        .movw,
        .mul,
        .progmem,
        .spm,
        .sram,
    }),
};
pub const os = std.Target.Os{
    .tag = .freestanding,
    .version_range = .{ .none = {} },
};
pub const target = std.Target{
    .cpu = cpu,
    .os = os,
    .abi = abi,
    .ofmt = object_format,
};
pub const object_format = std.Target.ObjectFormat.elf;
pub const mode = std.builtin.Mode.ReleaseSmall;
pub const link_libc = false;
pub const link_libcpp = false;
pub const have_error_return_tracing = false;
pub const valgrind_support = false;
pub const sanitize_thread = false;
pub const position_independent_code = false;
pub const position_independent_executable = false;
pub const strip_debug_info = false;
pub const code_model = std.builtin.CodeModel.default;
