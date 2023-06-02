PORT ?= /dev/ttyUSB0

.PHONY: all
all: flash

.PHONY: build
build:
	zig build
	avr-objdump zig-out/bin/app -d > zig-out/bin/app.lst
	avr-size zig-out/bin/app

.PHONY: flash
flash: build
	avr-objcopy -O ihex zig-out/bin/app zig-out/bin/app.hex
	pymcuprog -t uart -d attiny412 -u $(PORT) --erase write -f zig-out/bin/app.hex --verify