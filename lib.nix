inputs: let
  nixpkgs = inputs.nixpkgs.lib;
  flake-utils = inputs.flake-utils.lib;
in rec {
    linuxSystems = builtins.filter (nixpkgs.hasSuffix "linux") flake-utils.defaultSystems;
    darwinSystems = builtins.filter (nixpkgs.hasSuffix "darwin") flake-utils.defaultSystems;

    defaultFilesInDir = directory:
      nixpkgs.pipe (nixpkgs.filesystem.listFilesRecursive directory) [
        (builtins.filter (name: nixpkgs.hasSuffix "default.nix" name))
      ];

    fileAttrset = file: {
      name = builtins.baseNameOf (builtins.dirOf file);
      value = import file;
    };

    defaultFilesAttrset = directory:
      nixpkgs.pipe (defaultFilesInDir directory) [
        (map (file: {
          name = builtins.baseNameOf (builtins.dirOf file);
          value = import file;
        }))
        (builtins.listToAttrs)
      ];

    flattenAttrset = attrs: builtins.foldl' nixpkgs.mergeAttrs {} (builtins.attrValues attrs);

    forAllSystems = nixpkgs.genAttrs flake-utils.defaultSystems;

    pkgsBySystem = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  }
