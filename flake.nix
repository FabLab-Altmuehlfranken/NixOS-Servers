{
  inputs = {
    attic = { url = "github:zhaofengli/attic"; };
    deploy-rs = { url = "github:serokell/deploy-rs"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, attic }: {
    nixosConfigurations = {
      attic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            nix = {
              package = pkgs.nixFlakes;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
              registry.nixpkgs.flake = nixpkgs;
            };
            environment.systemPackages = [
              attic.packages.x86_64-linux.attic-client
            ];

            imports = [
              ./defaults.nix
              ./hosts/attic/configuration.nix
              attic.nixosModules.atticd
            ];
          })
        ];
      };
    };

    deploy.nodes = {
      "attic" = {
        sshOpts = [ "-p" "222" "-o" "StrictHostKeyChecking=no" ];
        hostname = "10.0.230.106";
        fastConnection = true;

        profiles.system = {
          sshUser = "root";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."attic";
          user = "root";
        };
      };
    };


    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    } // utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            deploy-rs.defaultPackage.${system}
            nixpkgs-fmt
          ];
        };
      }
  };
}
