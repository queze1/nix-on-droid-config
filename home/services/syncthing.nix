{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.services.syncthing-runit;
in
{
  options.services.syncthing-runit = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      syncthing
    ];

    services.runit.services.syncthing = {
      enable = true;
      run = ''
        exec ${pkgs.syncthing}/bin/syncthing
      '';
    };
  };
}
