# MSP430 GCC Toolchain for NixOS

Integration of Texas Instruments MSP430 GCC toolchain with fixes for NixOS compatibility.

## Issues Fixed

The original derivation failed on NixOS due to binary compatibility issues:

### 1. Dynamic Linker Problems
Original precompiled binaries couldn't find NixOS's dynamic linker.

**Fix**: Added comprehensive `patchelf` patching for all executable binaries:
```nix
# Main binaries (msp430-elf-gcc, etc.)
for binary in $out/bin/*; do
  patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) "$binary"
  patchelf --set-rpath "${pkgs.lib.makeLibraryPath buildInputs}" "$binary"
done

# LibExec binaries (cc1, cc1plus, lto1, etc.)
for binary in $(find $out/libexec -type f -executable); do
  # ... same patchelf commands
done

# MSP430-elf binaries (assembler, linker, etc.)
for binary in $out/msp430-elf/bin/*; do
  # ... same patchelf commands
done
```

### 2. Missing Dependencies
Original derivation lacked required build inputs and runtime dependencies.

**Fix**: Added proper dependencies:
```nix
nativeBuildInputs = with pkgs; [
  unzip
  patchelf
];

buildInputs = with pkgs; [
  stdenv.cc.cc.lib
  glibc
  zlib
  ncurses5
];
```

### 3. Incomplete Binary Coverage
Original only patched main binaries, missing libexec and target-specific tools.

**Fix**: Extended patching to cover all three binary locations:
- `/bin/*` - Main user-facing tools
- `/libexec/gcc/msp430-elf/9.3.1/*` - Compiler backend tools
- `/msp430-elf/bin/*` - Target-specific binutils

## Test Program Usage

The `msp430-test` package compiles a simple LED blink program to verify toolchain functionality.

### Available Commands
```bash
# View compilation info
msp430-test-info

# Check compiled binary size
msp430-elf-size /run/current-system/sw/bin/msp430-test.elf

# View Intel HEX output
head /run/current-system/sw/bin/msp430-test.hex
```

### Test Program Details
- **Target**: MSP430G2553 (LaunchPad compatible)
- **Function**: Blinks LED on P1.0 with software delay
- **Outputs**: Both ELF and Intel HEX formats
- **Size**: ~50 bytes (46 text, 4 BSS)

### Integration
Add to system packages in your NixOS config:
```nix
environment.systemPackages = with pkgs; [
  msp430-gcc    # Full toolchain
  msp430-test   # Test program (optional)
];
```

The test program demonstrates that the complete compilation pipeline works: preprocessing, compilation, assembly, linking, and Intel HEX generation.