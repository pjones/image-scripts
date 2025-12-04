{
  description = "Peter's image scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # List of supported systems:
      supportedSystems = nixpkgs.lib.platforms.unix;

      # Function to generate a set based on supported systems:
      each = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          let pkgs = import nixpkgs { inherit system; };
          in f pkgs system);
    in
    {
      packages = each (pkgs: system: {
        default = self.packages.${system}.image-scripts;
        image-scripts = pkgs.callPackage ./. { };
      });

      overlays = {
        default = final: prev: {
          pjones = (prev.pjones or { }) // {
            image-scripts = self.packages.${prev.stdenv.hostPlatform.system}.image-scripts;
          };
        };
      };

      devShells = each (pkgs: system: {
        default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
    };
}
