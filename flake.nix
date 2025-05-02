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
    nix-fmt = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-fmt";
      ref = "0.0.6";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    formatter = nix-fmt.formatter;
    lib = import ./lib.nix inputs;

    tests = {
      testLinuxSystems = {
        expr = lib.linuxSystems;
        expected = ["aarch64-linux" "i686-linux" "x86_64-linux"];
      };

      testDarwinSystems = {
        expr = lib.darwinSystems;
        expected = ["aarch64-darwin" "x86_64-darwin"];
      };

      testDefaultFilesInDir = {
        expr = builtins.length (lib.defaultFilesInDir "${self}/testData");
        expected = 2;
      };

      testDataFileAttrset = {
        expr = lib.fileAttrset "${self}/testData/default.nix";
        expected = {
          name = "testData";
          value = { a = "test"; };
        };
      };

      testNestedFileAttrset = {
        expr = lib.fileAttrset "${self}/testData/nested/default.nix";
        expected = {
          name = "nested";
          value = { a = "nest"; };
        };
      };

      testFlattenAttrs = {
        expr = lib.flattenAttrset {
          foo = { baz = { a = 1; }; };
          bar = { bah = { b = 1; }; };
        };
        expected = {
          baz = { a = 1; };
          bah = { b = 1; };
        };
      };

      testFlattenAttrsOverwrite = {
        expr = lib.flattenAttrset {
          foo = { baz = { a = 1; }; };
          bar = { baz = { b = 2; }; };
        };
        expected = {
          baz = { a = 1; };
        };
      };

      testFlattenAttrsOverwriteReverse = {
        expr = lib.flattenAttrset {
          foo = { baz = { b = 2; }; };
          bar = { baz = { a = 1; }; };
        };
        expected = {
          baz = { b = 2; };
        };
      };

      testForAllSystems = {
        expr = lib.forAllSystems (system: { a = system; });
        expected = {
          aarch64-darwin = { a = "aarch64-darwin"; };
          aarch64-linux = { a = "aarch64-linux"; };
          i686-linux = { a = "i686-linux"; };
          x86_64-darwin = { a = "x86_64-darwin"; };
          x86_64-linux = { a = "x86_64-linux"; };
        };
      };
    };
  }
  // flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {inherit system;};
  in {
    checks = {
      fmt = nix-fmt.checks.${system}.fmt;
      # test = pkgs.stdenvNoCC.mkDerivation {
      #   name = "test";
      #   src = ./.;
      #   dontBuild = true;
      #   doCheck = true;
      #   nativeBuildInputs = with pkgs; [nix-unit];
      #   checkPhase = ''
      #     nix-unit --impure --extra-experimental-features flakes --flake ${self}#tests
      #   '';
      #   installPhase = "mkdir \"$out\"";
      # };
    };

    devShells = {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [alejandra nix-unit];
      };

      githubActions = pkgs.mkShellNoCC {
        packages = with pkgs; [j2cli nix-unit];
      };
    };
  });
}
