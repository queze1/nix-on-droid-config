{ config, pkgs, ... }:
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

  # Tell agenix where to find SSH keys
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
    secrets = {
      cloudflare-tunnel-token = {
        file = ../secrets/cloudflare-tunnel-token.age;
        path = "/etc/cloudflare-tunnel-token";
      };
    };
  };

  # Read the changelog before changing this value
  home.stateVersion = "24.05";
}
