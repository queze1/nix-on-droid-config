{ config, lib, ... }:
{
  options = {
    systemd.user.services = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {
        agenix = {
          Service.ExecStart = "";
        };
      };
    };
  };

  config = {
    # Use build.activation instead of systemd
    build.activation.agenix = ''
      echo "Decrypting secrets with agenix..."
      echo ${config.systemd.user.services.agenix.Service.ExecStart}
      $DRY_RUN_CMD ${config.systemd.user.services.agenix.Service.ExecStart}
    '';
  };
}
