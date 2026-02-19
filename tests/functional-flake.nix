{
  outputs = _: {
    packages.x86_64-linux.default =
      let
        # minimal mock pkgs with inline lib implementation
        pkgs = {
          lib = {
            head = list: builtins.elemAt list 0;
            concatMap = f: list: builtins.concatLists (map f list);
            mapAttrsToList =
              f: attrs:
              map (name: f name attrs.${name}) (builtins.attrNames attrs);
            removeAttrs = attrs: names: builtins.removeAttrs attrs names;
            concatStringsSep = sep: list: builtins.concatStringsSep sep list;
            getExe = pkg: "${pkg}/bin/nix";
          };
          nixVersions.latest = {
            outPath = "/nix";
            pname = "nix";
          };
          nix = {
            outPath = "/bin/nix";
          };
          coreutils = {
            outPath = "/bin";
          };
          bashInteractive = {
            outPath = "/bin/bash";
          };
          git = {
            outPath = "/bin/git";
          };
          cacert = {
            outPath = "/etc/ssl/certs";
          };
          dockerTools.buildLayeredImageWithNixDb =
            args:
            derivation {
              name = args.name;
              builder = "/bin/bash";
              args = [
                "-c"
                "touch $out"
              ];
              system = "x86_64-linux";
              PATH = "/bin";
            };
        };
        mkBuildContainer = import ./mkbuildcontainer.nix;
      in
      mkBuildContainer {
        inherit pkgs;
        name = "test-container";
        inputsFrom = [ pkgs.coreutils ];
      };
  };
}
