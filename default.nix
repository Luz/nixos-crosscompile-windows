let
  lib = (import <nixpkgs> {}).lib;
  pkgs-cross-xx = hostArch:
    lib.mapAttrs
      (name_: pkg: if lib.isDerivation pkg then pkg.crossDrv else pkg)
      (pkgs-cross-xx-nocross hostArch);
  pkgs-cross-xx-nocross = hostArch:
      (import <nixpkgs> {
        crossSystem = {
          config = hostArch + "-w64-mingw32";
          arch = if hostArch == "i686" then "x86" else hostArch; # Irrelevant
          libc = "msvcrt"; # This distinguishes the mingw (non posix) toolchain
          platform = {};
          openssl.system = "mingw"
            + lib.optionalString (hostArch == "x86_64") "64";
        };
      });
in {
  w32 = pkgs-cross-xx "i686";
  w64 = pkgs-cross-xx "x86_64";

  w32-native = pkgs-cross-xx-nocross "i686";
  w64-native = pkgs-cross-xx-nocross "x86_64";
}

