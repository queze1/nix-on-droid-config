{ config, lib, ... }:
{
  options = {
    systemd.user.services = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };
  };

  config = {
    config = lib.mkIf (config.secrets != { }) {
      build.activation.agenix = ''
        $VERBOSE_ECHO "Decrypting secrets with agenix..."
        $DRY_RUN_CMD ${config.systemd.user.services.agenix.Service.ExecStart}
      '';
    };
  };
}
