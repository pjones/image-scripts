{ pkgs ? import <nixpkgs> { }
}:
let
  lib = pkgs.lib;
  stdenv = pkgs.stdenvNoCC;

  deps = with pkgs; [
    bash
    exiftool
  ];

  path = lib.makeBinPath deps;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "image-scripts";
  meta.description = "Peter's image scripts";

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
  buildInputs = deps ++ [ pkgs.makeWrapper ];
  src = ./.;

  installPhase = ''
    mkdir -p "$out/bin" "$out/wrapped"

    for file in bin/*; do
      name=$(basename "$file")
      install -m 0555 "$file" "$out/wrapped"

      makeWrapper "$out/wrapped/$name" "$out/bin/$name" \
        --prefix PATH : "${path}"
    done
  '';
}
