{ pkgs ? import <nixpkgs> {} }:

let 
  unstable = import <nixos-unstable> {};
in pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cargo
    gcc
    unstable.rustc # TODO: revert back to stable once 1.65.0 is merged
  ];
  buildInputs = with pkgs; [
    cargo-watch
    clippy
    rust-analyzer
    rustfmt
  ];

  RUST_BACKTRACE = 1;
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
