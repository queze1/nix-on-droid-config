{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  caddyWithTailscale = pkgs.caddy.withPlugins {
    # Last updated 27/04/2026
    plugins = [ "github.com/tailscale/caddy-tailscale@bb080c4414acd465d8be93b4d8f907dbb2ab2544" ];
    hash = lib.fakeHash;
  };
in
{
  home.packages = with pkgs; [
    # Services
    caddyWithTailscale
    cloudflared
    filebrowser
    navidrome
    pkgs-unstable.sillytavern
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
    syncthing
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "queze1";
      user.email = "52340127+queze1@users.noreply.github.com";
      init.defaultBranch = "main";
      push = {
        autoSetupRemote = "true";
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };
}
