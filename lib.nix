{
  mkBuildContainer =
    {
      pkgs,
      drv ? null,
      inputsFrom ? [ ],
      name ? "${if drv != null then (drv.pname or drv.name or "unnamed") else "env"}-build-container",
      nix ? pkgs.nixVersions.latest,
      nixConf ? ''
        experimental-features = nix-command flakes
      '',
      ...
    }@args:
    let
      inherit (pkgs) lib;

      allDrvs = (if drv != null then [ drv ] else [ ]) ++ inputsFrom;

      extractedInputs = lib.concatMap (
        d:
        lib.concatMap (attr: d.${attr} or [ ]) [
          "buildInputs"
          "nativeBuildInputs"
          "propagatedBuildInputs"
          "propagatedNativeBuildInputs"
        ]
      ) allDrvs;

      contents = [
        nix
      ]
      ++ (with pkgs; [
        bashInteractive # for debug, only adds 4MB
        cacert # for fetchers
      ])
      ++ extractedInputs
      ++ args.contents or [ ];

      config = {
        Entrypoint = [ (lib.getExe nix) ];
        Env = lib.mapAttrsToList (name: value: "${name}=${value}") {
          USER = "root";
          # requires "sandbox = false" because unprivileged containers lack the
          # kernel privileges (unshare for namespaces) required to create it
          # we also disable build-users-group because containers often lack them
          NIX_CONFIG = ''
            sandbox = false
            build-users-group =
            ${nixConf}
          '';
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          PATH = "/bin:/usr/bin:/sbin:/usr/sbin";
        };
      };

      image = pkgs.dockerTools.buildLayeredImageWithNixDb (
        (lib.removeAttrs args [
          "contents"
          "config"
          "drv"
          "inputsFrom"
          "nix"
          "nixConf"
          "pkgs"
        ])
        // {
          inherit name contents config;
          # nix needs /tmp to build
          extraCommands = "mkdir -m 1777 tmp";
        }
      );
    in
    # expose metadata for unit testing and inspection. buildLayeredImageWithNixDb
    # does not support passthru or automatically export its internal arguments
    image // { inherit contents config; };
}
