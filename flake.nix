{

  description = "Zero-setup Nix builds for GitHub actions";

  nixConfig = {
    extra-substituters = [ "https://nix-zero-setup.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-zero-setup.cachix.org-1:lNgsI3Nea9ut1dJDTlks9AHBRmBI+fj9gIkTYHGtAtE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    inputs:
    let
      lib = import ./lib.nix;
    in
    {
      inherit lib;
    }
    // inputs.flake-utils.lib.eachSystem (import inputs.systems) (
      system:
      let

        pkgs = inputs.nixpkgs.legacyPackages.${system};

        build-container = lib.mkBuildContainer {
          inherit pkgs;
          name = "nix-zero-setup";
          tag = inputs.self.rev or inputs.self.dirtyRev or null;
        };

      in
      {

        checks = {
          unit = import ./tests/unit.nix { inherit pkgs; };
          functional = import ./tests/functional.nix {
            inherit pkgs;
            inherit build-container;
          };
        };

        packages = {
          inherit build-container;
          default = build-container;
        };

      }
    );

}
