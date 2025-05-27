let
  rustOverlay = import (builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
  });

  nixpkgs = import <nixpkgs> {
    overlays = [ rustOverlay ];
  };

  rust = nixpkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

  getLib = pkg: "${pkg}/lib";
  libiconvPath = getLib nixpkgs.libiconv;
in
nixpkgs.mkShell {
  buildInputs = with nixpkgs; [
    pkg-config
    libiconv
    llvmPackages.llvm
    llvmPackages.clang
    rust
  ];

  LD_LIBRARY_PATH = nixpkgs.lib.makeLibraryPath [
    (getLib nixpkgs.llvmPackages.llvm)
    libiconvPath
  ];

  NIX_LDFLAGS = "-L${libiconvPath}";
}
