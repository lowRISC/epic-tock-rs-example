# RISC-V Embedded PIC Tock OS Rust App Example

## Overview

lowRISC is working on a specification and [prototype toolchain implementation](https://github.com/lowRISC/llvm-project/commits/epic) of an Embedded PIC (ePIC) ABI for RISC-V.

This repository illustrates how to use the work-in-progress ePIC toolchain implementation to create relocatable RISC-V Tock OS applications. It builds a libtock-rs `console` example app with an ePIC configuration and runs it under QEMU. The example prints the addresses and values of some program symbols, to demonstrate the relocation capabilities.

## Building and Running

Build requirements:

- LLVM build dependencies

The other dependencies are installed automatically. This example has been tested against Tock commit `935755eb3`.

Use `cmake -S . -B ./build -G Ninja` to configure the project and `cmake --build ./build` to build everything.

If you already have ePIC enabled LLVM and `rustc` builds, you can specify their locations with `LLVM_DIR` and `RUST_DIR`.
For example: `cmake -S . -B ./build -G Ninja -DLLVM_DIR=/path/to/epic-llvm -DRUST_DIR=/path/to/epic-rust`.
LLVM binaries will be searched in `${LLVM_DIR}/bin/` and rustc binaries will be searched in `${RUST_DIR}/bin`.

Use `cmake --build ./build -- run-console-hifive1` to run the app in hifive1, and `cmake --build ./build -- run-console-opentitan_earlgrey_cw310` to run the app in opentitan.

### Compile error `error: fixup value out of range`

This error can be triggered by uncommenting line 39 in `libtock-rs/libtock2/examples/console.rs`.
Trying to run the example on either platform (`hifive1` or `opentitan`) will result in the compile time error `error: fixup value out of range`.

### Wrong `.data` section offset in the `crt0_header`

Currently there is a workaround in place for this issue.
To disable the workarround comment out the `.padding` section in `libtock-rs/runtime/libtock_layout.ld` (lines 135 through 138).

The `crt0_header` contains a `data_sym_start` entry, which indicates the start of the `.data` section in FLASH memory.
This entry is computed in the linker script as `LONG(LOADADDR(.data) - ORIGIN(FLASH))`.

It seems that in some cases (depending on the size of the generated sections), the value of `LOADADDR(.data)` is wrongly computed.
In the shipping example, that should be computed as `0x80002AF4`, but instead results in `0x80002AF8` (i.e., 4 bytes forward of its actual value).

This results in the initialization of the `.data` section in RAM being incorrect, and resulting in the wrong relocations being applied.

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache License, Version 2.0 (see [LICENSE](LICENSE) for full text).
