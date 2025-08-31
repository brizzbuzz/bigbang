{pkgs, ...}: let
  msp_bin = pkgs.fetchurl {
    url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-LlCjWuAbzH/9.3.1.2/msp430-gcc-9.3.1.11_linux64.tar.bz2";
    hash = "sha256-tghRthVl493SGTKYo/rFEgwkAllxdBBsxfhIK56ZhuY=";
  };

  msp_support = pkgs.fetchurl {
    url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-LlCjWuAbzH/9.3.1.2/msp430-gcc-support-files-1.212.zip";
    hash = "sha256-Oxo58Qo0Tf77dn5grDW+zvTAZQE76GmTGVsTil+wuNY=";
  };
in
  pkgs.stdenv.mkDerivation rec {
    pname = "msp430-gcc";
    version = "9.3.1.11";

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

    srcs = [
      msp_bin
      msp_support
    ];

    sourceRoot = ".";

    # Custom unpack phase to handle multiple archives
    unpackPhase = ''
      runHook preUnpack

      # Extract the main compiler tarball
      tar -xjf ${msp_bin}

      # Extract the support files
      unzip -q ${msp_support}

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      echo "Contents of current directory:"
      ls -la

      echo "Contents of msp430-gcc directory:"
      ls -la msp430-gcc-9.3.1.11_linux64/ || true

      echo "Contents of support files:"
      ls -la msp430-gcc-support-files/ || true

      # Create output directories
      mkdir -p $out/{bin,include,lib,lib64,libexec,msp430-elf,share}

      # Copy main compiler files
      if [ -d "msp430-gcc-9.3.1.11_linux64" ]; then
        cp -r msp430-gcc-9.3.1.11_linux64/bin/* $out/bin/
        cp -r msp430-gcc-9.3.1.11_linux64/include/* $out/include/
        cp -r msp430-gcc-9.3.1.11_linux64/lib/* $out/lib/
        cp -r msp430-gcc-9.3.1.11_linux64/lib64/* $out/lib64/
        cp -r msp430-gcc-9.3.1.11_linux64/libexec/* $out/libexec/
        cp -r msp430-gcc-9.3.1.11_linux64/msp430-elf/* $out/msp430-elf/
        cp -r msp430-gcc-9.3.1.11_linux64/share/* $out/share/

        # Copy version file if it exists
        if [ -f "msp430-gcc-9.3.1.11_linux64/version.properties" ]; then
          cp msp430-gcc-9.3.1.11_linux64/version.properties $out/
        fi
      fi

      # Copy support files
      if [ -d "msp430-gcc-support-files/include" ]; then
        cp -r msp430-gcc-support-files/include/* $out/include/
      fi

      runHook postInstall
    '';

    # Manually patch only host executables, skip MSP430 target files
    postFixup = ''
      # Make all binaries executable
      find $out -type f -executable -exec chmod +x {} \;

      # Only patch ELF executables in bin/ directory (skip MSP430 target files)
      for binary in $out/bin/*; do
        if [ -f "$binary" ] && file "$binary" | grep -q "ELF.*executable"; then
          echo "Patching $binary"
          patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) "$binary" || true
          patchelf --set-rpath "${pkgs.lib.makeLibraryPath buildInputs}" "$binary" || true
        fi
      done
    '';

    # Add some basic metadata
    meta = with pkgs.lib; {
      description = "MSP430 GCC compiler toolchain from Texas Instruments";
      homepage = "https://www.ti.com/tool/MSP430-GCC-OPENSOURCE";
      license = licenses.gpl3Plus;
      platforms = ["x86_64-linux"];
      maintainers = [];
    };
  }
