# e2e test: build actual example projects
{ pkgs, mkBuildContainer, flake-utils, pyproject-nix }:
let
  inherit (pkgs) system;

  # mock nix-zero-setup input for examples
  nixZeroSetup = {
    lib = { inherit mkBuildContainer; };
  };

  # mock nixpkgs input
  nixpkgs = {
    legacyPackages.${system} = pkgs;
  };

  # import and build each example
  cppBoost =
    (import ../examples/cpp-boost/flake.nix).outputs {
      self = { };
      inherit nixpkgs;
      inherit flake-utils;
      nix-zero-setup = nixZeroSetup;
    };

  rustApp =
    (import ../examples/rust-app/flake.nix).outputs {
      self = { };
      inherit nixpkgs;
      inherit flake-utils;
      nix-zero-setup = nixZeroSetup;
    };

  pythonExample =
    (import ../examples/python/flake.nix).outputs {
      self = { };
      inherit nixpkgs flake-utils pyproject-nix;
      nix-zero-setup = nixZeroSetup;
    };

in
pkgs.runCommand "e2e-examples"
  {
    cppContainer = cppBoost.packages.${system}.nix-build-container;
    rustContainer = rustApp.packages.${system}.nix-build-container;
    pythonContainer = pythonExample.packages.${system}.nix-build-container;
  }
  ''
    echo "Verifying example containers..."
    for img in $cppContainer $rustContainer $pythonContainer; do
      test -f "$img" || { echo "Missing: $img"; exit 1; }
      echo "OK: $img"
    done
    mkdir -p $out
    echo "All e2e checks passed" > $out/result
  ''
