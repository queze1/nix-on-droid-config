{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.actual-server;
in {
  options.services.actual-server = {
    enable = mkEnableOption "Actual Server";

    dataDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/share/actual";
      description = "Directory for Actual Server data.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [actual-server];

    services.runit.services.actual-server = {
      enable = true;
      run = ''
        mkdir -p ${cfg.dataDirectory}
        export ACTUAL_DATA_DIR="${cfg.dataDirectory}"
        export ACTUAL_HOSTNAME="127.0.0.1"
        exec ${pkgs.actual-server}/bin/actual-server
      '';
    };
  };
}
