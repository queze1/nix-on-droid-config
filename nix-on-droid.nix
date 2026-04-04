{
  pkgs,
  ...
}:
{
  imports = [ ./modules ];

  # Add openssh into PATH before activating
  build.activationBefore.sshPath = ''
    export PATH=$PATH:${pkgs.openssh}/bin
  '';

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };

  # Set time zone
  time.timeZone = "Australia/Sydney";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";
}
