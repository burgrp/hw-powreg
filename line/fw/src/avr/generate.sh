#!/bin/sh

set -e

    cat >chips.zig <<EOF
const std = @import("std");
const micro = @import("../../deps/microzig/build.zig");
const Chip = micro.Chip;
const MemoryRegion = micro.MemoryRegion;

// Generated file, do not edit.

fn root_dir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
EOF

for ATDF in `ls atdf/*.atdf`
do
    GEN_ZIG=$(echo $ATDF | sed 's/atdf/chips/;s/atdf/zig/')
    regz $ATDF -o $GEN_ZIG 2>&1| grep -v "^debug"

    GEN_JSON=$(echo $ATDF | sed 's/atdf/chips/;s/atdf/json/')
    regz $ATDF -j -o $GEN_JSON 2>&1| grep -v "^debug"

    DECL_FLASH=$(cat atdf/ATtiny412.atdf | xq | sed "s/@//g;s/-//g" | jq '.avrtoolsdevicefile.devices.device.addressspaces.addressspace[]|select(.id=="prog").memorysegment|"MemoryRegion{ .offset = \(.start), .length = \(.size), .kind = .\(.type) },"'|sed 's/"//g')
    DECL_RAM=$(cat atdf/ATtiny412.atdf | xq | sed "s/@//g;s/-//g" | jq '.avrtoolsdevicefile.devices.device.addressspaces.addressspace[]|select(.id=="data").memorysegment[]|select(.type=="ram")|"MemoryRegion{ .offset = \(.start), .length = \(.size), .kind = .\(.type) },"'|sed 's/"//g')

    ZIG_NAME=$(echo $ATDF | sed 's/atdf\///;s/\.atdf//')
    ZIG_VAR=$(echo $ZIG_NAME | tr '[:upper:]' '[:lower:]')

    cat >>chips.zig <<EOF

pub const $ZIG_VAR = Chip{
    .name = "$ZIG_NAME",
    .cpu = micro.cpus.avr5,
    .memory_regions = &.{
        $DECL_FLASH
        $DECL_RAM
    },
    .source = .{
        .path = root_dir() ++ "/$GEN_ZIG",
    },
};
EOF

done
