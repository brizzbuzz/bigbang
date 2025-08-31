{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "msp430-test";
  version = "1.0.0";

  src = pkgs.writeTextFile {
    name = "msp430-test.c";
    text = ''
      #include <msp430.h>

      int main(void) {
          // Stop watchdog timer
          WDTCTL = WDTPW | WDTHOLD;

          // Set P1.0 as output (LED on LaunchPad)
          P1DIR |= BIT0;

          // Simple delay loop and LED toggle
          volatile unsigned int i;
          while(1) {
              P1OUT ^= BIT0;  // Toggle LED

              // Delay
              for(i = 10000; i > 0; i--);
          }

          return 0;
      }
    '';
  };

  nativeBuildInputs = with pkgs; [
    msp430-gcc
  ];

  unpackPhase = ''
    cp ${src} msp430-test.c
  '';

  buildPhase = ''
    msp430-elf-gcc -mmcu=msp430g2553 -Os -Wall -g -I${pkgs.msp430-gcc}/include -L${pkgs.msp430-gcc}/include msp430-test.c -o msp430-test.elf
    msp430-elf-objcopy -O ihex msp430-test.elf msp430-test.hex
    msp430-elf-size msp430-test.elf
  '';

  installPhase = ''
        mkdir -p $out/bin
        cp msp430-test.elf $out/bin/
        cp msp430-test.hex $out/bin/

        # Create a simple script to show compilation was successful
        cat > $out/bin/msp430-test-info << EOF
    #!/bin/sh
    echo "MSP430 Test Program compiled successfully!"
    echo "ELF file: \$out/bin/msp430-test.elf"
    echo "HEX file: \$out/bin/msp430-test.hex"
    msp430-elf-size \$out/bin/msp430-test.elf
    EOF
        chmod +x $out/bin/msp430-test-info
  '';

  meta = with pkgs.lib; {
    description = "Simple MSP430 test program to verify toolchain";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
  };
}
