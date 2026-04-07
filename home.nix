{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "rebuild" ''
      cd ~/.config/nix-on-droid-config/
      git pull
      nix-on-droid switch --flake .
    '')
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "builder" = {
        # utm-vm
        hostname = "100.95.108.111";
        user = "remotebuild";
        identityFile = "/data/data/com.termux.nix/files/home/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };

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

  xdg.dataFile.sillytavern-config = {
    enable = true;
    target = "SillyTavern/config.yaml";
    source = ./config/sillytavern.yaml;
  };

  xdg.configfile.navidrome-config = {
    enable = true;
    target = "navidrome.toml";
    source = ./config/navidrome.toml;
  };

  services.syncthing = {
    enable = true;
  };

  # Read the changelog before changing this value
  home.stateVersion = "24.05";
}
