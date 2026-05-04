{ ... }:
{
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
