{
  description = "Nix utility library";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.*";
    outputs =
      {
        self,
        nixpkgs,
        flake-schemas,
        ...
      }@inputs:
      rec {
        inherit (self) outputs;
        schemas = flake-schemas.schemas;
        lib = import ./lib.nix inputs;

        formatter = lib.forAllSystems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          pkgs.nixfmt-rfc-style
        );
      };
  };
}
