{ pkgs }:
let
  pythonEnv = pkgs.python3.withPackages (_: [ ]);
  script = pkgs.writeTextFile {
    name = "github-example.py";
    text = ''print("Nix Seed. Accept no substitute")'';
  };
in
pkgs.stdenv.mkDerivation {
  pname = "github-example";
  version = "0.1.0";
  src = script;
  buildCommand = ''
    mkdir -p $out/bin
    cp ${script} $out/bin/main.py
    chmod +x $out/bin/main.py
    printf '#!${pythonEnv}/bin/python\n' | cat - $out/bin/main.py > $out/bin/main
    chmod +x $out/bin/main
  '';
}
