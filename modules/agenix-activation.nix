{ config, lib, ... }:
{
  options = {
    systemd.user.services = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };
  };

  config = {
    # Use build.activation instead of systemd
    build.activation.agenix = ''
      $VERBOSE_ECHO "Decrypting secrets with agenix..."
      $DRY_RUN_CMD ${config.systemd.user.services.agenix.Service.ExecStart}
    '';
  };
}
