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
      fmt-check = pkgs.stdenvNoCC.mkDerivation {
        name = "fmt-check";
        src = ./.;
        dontBuild = true;
        doCheck = true;
        nativeBuildInputs = with pkgs; [alejandra];
        checkPhase = ''
          alejandra -c .
        '';
        installPhase = ''
          mkdir "$out"
        '';
      };
    in {
      checks = {inherit fmt-check;};
      formatter = pkgs.alejandra;
    });
}
