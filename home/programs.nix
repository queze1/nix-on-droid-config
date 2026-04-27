{ pkgs, pkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    # Init manager
    runit

    # Services
    caddy
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
