{
  pkgs,
  agenix,
  ...
}:
{
  imports = [ ./modules ];

  user.uid = 10273;
  user.gid = 10273;

  environment.systemPackages = [ agenix.packages.aarch64-linux.default ];

  # Add tools to activation PATH
  build.activationBefore.extendPath = ''
    export PATH=$PATH:${pkgs.openssh}/bin:${pkgs.git}/bin
  '';

  # Backup if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    sharedModules = [ agenix.homeManagerModules.default ];
  };

  # Set time zone
  time.timeZone = "Australia/Sydney";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";
}
