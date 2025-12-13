{ pkgs ? import <nixpkgs> {} }:

let
  py = pkgs.python3Packages;
  unstable = import <nixos-unstable> {};
in pkgs.mkShell {
  name = "aoc";
  venvDir = "./venv";
  nativeBuildInputs = with pkgs; [
    cargo
    gcc
    rustc
  ];
  buildInputs = with pkgs; [
    # Golang
    go

    # OCaml
    ocamlPackages.ocaml
    ocamlPackages.containers
    ocamlPackages.dune_3
    ocamlPackages.findlib
    ocamlPackages.janeStreet.ppx_expect
    ocamlPackages.ocaml-lsp
    ocamlPackages.odoc
    ocamlPackages.utop
    ocamlPackages.zarith
    ocamlformat

    # Python
    py.numpy
    py.python
    py.venvShellHook

    # Ruby
    ruby

    # Rust
    clippy
    rust-analyzer
    rustfmt

    # TypeScript
    nodejs
    typescript

    # Zig
    zig
  ];
  postEnvCreation = ''
    pip install -r requirements.txt
  '';

  RUST_BACKTRACE = 1;
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
