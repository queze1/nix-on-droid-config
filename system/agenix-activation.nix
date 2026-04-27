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
      $VERBOSE_ECHO "Decrypting secrets with agenix..."
      $DRY_RUN_CMD ${config.systemd.user.services.agenix.Service.ExecStart}
    '';

    # Set up temporary runtime directory
    environment.sessionVariables = {
      XDG_RUNTIME_DIR = "${config.user.home}/.run";
    };

    build.activation.setupRuntimeDir = ''
      $DRY_RUN_CMD rm -rf ${config.user.home}/.run
      $DRY_RUN_CMD mkdir -p ${config.user.home}/.run
      $DRY_RUN_CMD chmod 700 ${config.user.home}/.run
    '';
  };
}
