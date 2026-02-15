{
  description = "Example C++ project using Boost and nix-zero-build";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nix-zero-build = {
      url = "github:your-org/nix-zero-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachSystem (import inputs.systems) (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "cpp-boost-example";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = with pkgs; [
            cmake
            ninja
          ];
          buildInputs = with pkgs; [ boost ];
        };

        packages.build-container = (inputs.nix-zero-build.lib pkgs).mkBuildContainer {
          name = "cpp-boost-build-env";
          contents = with pkgs; [
            cmake
            ninja
            gcc
            boost
          ];
        };
      }
    );
}
