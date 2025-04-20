{
  description = "Nix utility library";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.*";
  };

  outputs = {
    self,
    nixpkgs,
    flake-schemas,
    flake-utils,
    ...
  } @ inputs:
    rec {
      schemas = flake-schemas.schemas;
      lib = import ./lib.nix inputs;
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      fmt-check = pkgs.stdenv.mkDerivation {
        name = "fmt-check";
        src = ./.;
        doCheck = true;
        nativeBuildInputs = with pkgs; [alejandra shellcheck shfmt];
        checkPhase = ''
          shfmt -d -s -i 2 -ci ${files}
          alejandra -c .
          shellcheck -x ${files}
        '';
      };
    in {
      checks = {inherit fmt-check;};
      formatter = pkgs.alejandra;
    });
}
