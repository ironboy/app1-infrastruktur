{
  description = "App att gå live med för deluppgift 1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =  { self, nixpkgs, flake-utils, ... }: let
    name = "app1-infrastruktur";
  in
    flake-utils.lib.eachDefaultSystem(system: {
      packages = let 
        pkgs = import nixpkgs { inherit system; };

        inherit (pkgs) buildNpmPackage callPackage;

        pkg = callPackage ({ buildNpmPackage }: 
          buildNpmPackage {
            inherit name;
            src = ./.;
            npmDepsHash = "sha256-0P6v9FxBg6AeuhpfuJ9jRk9rW678HdAtxsRBoZIem8s=";
          }
        ) { };
      in { default = pkg; ${name} = pkg; };
    });
}

