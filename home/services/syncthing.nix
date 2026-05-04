{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    ;

  cfg = config.services.syncthing;
in
{
  # Override Home Manager services.syncthing as it relies on systemd
  options.services.syncthing = mkForce {
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
