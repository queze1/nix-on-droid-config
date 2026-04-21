{ config, lib, ... }:
{
  options = {
    systemd.user.services = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };
  };

  config = {
    # Tell agenix where to find SSH keys
    age.identityPaths = [
      "${config.user.home}/.ssh/id_ed25519"
    ];

    # Use build.activation instead of systemd
    build.activation.agenix = ''
      $VERBOSE_ECHO "Decrypting secrets with agenix..."
      $DRY_RUN_CMD ${config.systemd.user.services.agenix.Service.ExecStart}
    '';
  };
}
