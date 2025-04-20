{
  description = "Nix utility library";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.*";
    flake-nix-fmt = {
      url = "github:Denis101/flake-nix-fmt/0.0.1";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-schemas,
    flake-utils,
    flake-nix-fmt,
    ...
  } @ inputs: rec {
    schemas = flake-schemas.schemas;
    checks = flake-nix-fmt.checks;
    formatter = flake-nix-fmt.formatter;
    lib = import ./lib.nix inputs;
  };
}
