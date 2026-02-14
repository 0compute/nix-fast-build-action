{

  description = "Fast Nix builds for GitHub actions";

  nixConfig = {
    extra-substituters = [ "https://nix-fast-build-action.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-fast-build-action.cachix.org-1:lNgsI3Nea9ut1dJDTlks9AHBRmBI+fj9gIkTYHGtAtE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    (inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;
      in
      {

        packages = {
          default = pkgs.dockerTools.buildLayeredImageWithNixDb {
            name = "nix-fast-build-action";
            tag = inputs.self.rev or inputs.self.dirtyRev or null;
            contents = with pkgs; [ bashInteractive ];
            config = {
              Cmd = [
                (lib.getExe pkgs.python3)
                "-c"
                "print('Hello from a layered Nix image!')"
              ];
            };
          };
        };

        apps.default = {
          type = "app";
          program = lib.getExe (
            pkgs.writeShellApplication {
              name = "ghcr push";
              text = ''
                nix build
                docker load < result
                name=ghcr.io/$GITHUB_REPOSITORY
                for tag in $GITHUB_SHA $(git describe --tags --always) latest; do
                  docker tag ''${GITHUB_REPOSITORY##*/}:$GITHUB_SHA $name:$tag
                done
                docker login ghcr.io --username "$GITHUB_ACTOR" --password-stdin <<< $GITHUB_TOKEN
                docker push --all-tags $name
              '';
              excludeShellChecks = [
                "2086" # Double quote to prevent globbing and word splitting
              ];
            }
          );
        };

      }
    ));

}
