{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./runit.nix
    ./services.nix
  ];

  home.packages = [
    (pkgs.writeShellScriptBin "rebuild" ''
      cd ~/.config/nix-on-droid-config/
      git pull
      nix-on-droid switch --flake .
    '')
  ];

  xdg.dataFile.sillytavern-config = {
    enable = true;
    target = "SillyTavern/config.yaml";
    source = ../config/sillytavern.yaml;
  };

  xdg.configFile.navidrome-config = {
    enable = true;
    target = "navidrome.toml";
    source = ../config/navidrome.toml;
  };

  age = {
    secretsDir = "${config.home.homeDirectory}/.run/agenix";
    secretsMountPoint = "${config.home.homeDirectory}/.run/agenix.d";
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
    secrets = {
      cloudflare-tunnel-token = {
        file = ../secrets/cloudflare-tunnel-token.age;
      };
    };
  };

  # Capture agenix systemd and run it as an activation script
  home.activation.agenix = ''
    echo "Decrypting secrets with agenix..."
    $DRY_RUN_CMD ${config.systemd.user.services.agenix.Service.ExecStart}
  '';

  home.activation.printAgenixExecStart = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Agenix ExecStart: ${lib.concatStringsSep " " config.systemd.user.services.agenix.Service.ExecStart}"
  '';

  # Read the changelog before changing this value
  home.stateVersion = "24.05";
}
