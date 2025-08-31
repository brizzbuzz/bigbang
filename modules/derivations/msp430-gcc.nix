{pkgs ? import <nixpkgs> {}, ...}: let
  msp_bin = pkgs.fetchurl {
    url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-LlCjWuAbzH/9.3.1.2/msp430-gcc-9.3.1.11_linux64.tar.bz2";
    hash = "sha256-tghRthVl493SGTKYo/rFEgwkAllxdBBsxfhIK56ZhuY=";
  };
  msp_support = pkgs.fetchurl {
    url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-LlCjWuAbzH/9.3.1.2/msp430-gcc-support-files-1.212.zip";
    hash = "sha256-Oxo58Qo0Tf77dn5grDW+zvTAZQE76GmTGVsTil+wuNY=";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "msp430-elf-gcc";
    version = "9.3.1.11";
    nativeBuildInputs = with pkgs; [
      unzip
    ];
    sourceRoot = ".";
    srcs = [
      msp_bin
      msp_support
    ];

    installPhase = ''
      ls -a
      mkdir -p $out/{bin,include,lib,lib64,libexec,msp430-elf,share}
      cp -r msp430-gcc-9.3.1.11_linux64/bin/* $out/bin
      cp -r msp430-gcc-9.3.1.11_linux64/include/* $out/include

      cp -r msp430-gcc-9.3.1.11_linux64/lib/* $out/lib
      cp -r msp430-gcc-9.3.1.11_linux64/lib64/* $out/lib64
      cp -r msp430-gcc-9.3.1.11_linux64/libexec/* $out/libexec

      cp -r msp430-gcc-9.3.1.11_linux64/msp430-elf/* $out/msp430-elf
      cp -r msp430-gcc-9.3.1.11_linux64/share/* $out/share

      cp msp430-gcc-9.3.1.11_linux64/version.properties $out

      cp -r msp430-gcc-support-files/include/*  $out/include
    '';
  }
