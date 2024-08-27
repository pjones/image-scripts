{
  description = "Peter's image scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # List of supported systems:
      supportedSystems = nixpkgs.lib.platforms.unix;

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        image-scripts = import ./. { pkgs = nixpkgsFor.${system}; };
        default = self.packages.${system}.image-scripts;
      });

      overlays = {
        default = final: prev: {
          pjones = (prev.pjones or { }) // {
            image-scripts = self.packages.${prev.system}.image-scripts;
          };
        };
      };

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in {
          default = pkgs.mkShell {
            inputsFrom = builtins.attrValues self.packages.${system};
          };
        });
    };
}
