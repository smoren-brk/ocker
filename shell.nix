{ pkgs ? import <nixpkgs> { } }:
with pkgs;

mkShell {
  buildInputs = [
    odin
    ols
  ];

  shellHook = ''
    printf "\nOcker develop shell\n\n"
    odin version
  '';
}
