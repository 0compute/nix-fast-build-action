# e2e test: build containers similar to the examples
{ pkgs, mkBuildContainer }:
let
  # simulate cpp-boost example
  cppContainer = mkBuildContainer {
    inherit pkgs;
    name = "cpp-boost-e2e";
    inputsFrom = [
      (pkgs.stdenv.mkDerivation {
        pname = "cpp-example";
        version = "0.0.0";
        src = pkgs.emptyDirectory;
        nativeBuildInputs = with pkgs; [ cmake ninja ];
        buildInputs = with pkgs; [ boost ];
        buildPhase = "true";
        installPhase = "mkdir -p $out";
      })
    ];
    contents = with pkgs; [ gcc ];
  };

  # simulate rust example
  rustContainer = mkBuildContainer {
    inherit pkgs;
    name = "rust-e2e";
    inputsFrom = [
      (pkgs.stdenv.mkDerivation {
        pname = "rust-example";
        version = "0.0.0";
        src = pkgs.emptyDirectory;
        nativeBuildInputs = with pkgs; [ rustc cargo ];
        buildPhase = "true";
        installPhase = "mkdir -p $out";
      })
    ];
    contents = with pkgs; [ rust-analyzer clippy ];
  };

  # simulate python example
  pythonContainer = mkBuildContainer {
    inherit pkgs;
    name = "python-e2e";
    contents = with pkgs; [ python3 black ];
  };
in
pkgs.runCommand "e2e-examples"
  {
    inherit cppContainer rustContainer pythonContainer;
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
