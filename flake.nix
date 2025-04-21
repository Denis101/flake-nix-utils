{
  description = "Nix utility library";

  inputs = {
    flake-schemas = {
      type = "github";
      owner = "DeterminateSystems";
      repo = "flake-schemas";
      ref = "refs/tags/v0.1.5";
    };
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "refs/tags/v1.0.0";
    };
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "24.11";
    };
    nix-unit = {
      type = "github";
      owner = "nix-community";
      repo = "nix-unit";
      ref = "v2.23.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-fmt = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-fmt";
      ref = "0.0.2";
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
    nix-fmt,
    ...
  } @ inputs: rec {
    schemas = flake-schemas.schemas;
    checks = nix-fmt.checks;
    formatter = nix-fmt.formatter;
    lib = import ./lib.nix inputs;

    tests = {
      linuxSystems = {
        expr = lib.linuxSystems;
        expected = [];
      };

      darwinSystems = {
        expr = lib.darwinSystems;
        expected = [];
      };
    };
  };
}
