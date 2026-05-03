{ pkgs, pkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    # Services
    (caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
      ];
      hash = "sha256-4WF7tIx8d6O/Bd0q9GhMch8lS3nlR5N3Zg4ApA3hrKw=";
    })

    cloudflared
    filebrowser
    navidrome
    pkgs-unstable.sillytavern
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
    syncthing
  ];

  programs = {
    bash.enable = true;
    git = {
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

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    ssh = {
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
  };
}
