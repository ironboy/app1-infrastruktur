{
  description = "App att gå live med för deluppgift 1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =  { self, nixpkgs, flake-utils, ... }: let
    name = "app1-infrastruktur";
  in
    flake-utils.lib.eachDefaultSystem(system: let

      pkgs = import nixpkgs { inherit system; };

      inherit (pkgs)
        buildNpmPackage
        writeShellScriptBin
      ;

      pkg = { node ? pkgs.nodejs-18_x, ... }: buildNpmPackage {
        inherit name;
        src = ./.;
        postInstall = ''
          rm $out/settings.json
        '';
      };

      # yoink the node set in the package definition above
      inherit (pkg) node; 

      seeder-name = "${name}-seeder";
      run-name = "${name}-run";

      nm_path = "${pkg}/lib/node_modules";
      NODE_PATH_export = "export NODE_PATH='${nm_path}'";

    in {
      packages.${name} = pkg;
      packages.${seeder-name} = writeShellScriptBin seeder-name ''
        ${NODE_PATH_export}
        cd "${nm_path}/_seed_db"
        ${node}/bin/node seeder.js
      '';
      packages.${run-name} = writeShellScriptBin run-name ''
        ${NODE_PATH_EXPORT}
        cd "${nm_path}/backend"
        "${node}/bin/node index.js
      '';

      packages.default = packages.${run-name};
    }
  ) // { 
  # now we add on non-system-specific stuff

    # add module
    nixosModules = let 
      module = { config, pkgs, lib, ... }: with lib; let
        cfg = config.services.${name};
        packages = self.packages.${pkgs.system};
      in {
        options.services.${name} = with types; {
          enable = mkEnableOption self.description;

          nodePkg = mkOption {
            type = package;
            default = pkgs.nodejs-18_x;
            description = ''
              Which node version to run the app with.
            '';
          };

          ensureCinemaDb = mkEnableOption {
            default = true;
            description = ''
              Ensures the mysql database 'cinema'. 
            '';
          };

          runSeeder = mkEnableOption {
            default = false;
            description = ''
              Run the seeder every time the service is started.
            '';
          };
        };

        config = mkIf cfg.enable {
          services.mysql = {
            enable = true;
            ensureDatabases = mkIf cfg.ensureCinemaDb [
              "cinema"
            ];
          };
        };
      };
    in { default = pkg; "${name}" = pkg; };
  };
}

