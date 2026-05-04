{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.services.sillytavern;
in
{
  options.services.sillytavern = {
    enable = mkEnableOption "sillytavern";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs-unstable; [ sillytavern ];

    xdg.dataFile.sillytavern-config = {
      enable = true;
      target = "SillyTavern/config.yaml";
      source = ./sillytavern.yaml;
    };

    services.runit.services.sillytavern = {
      enable = true;
      run = ''
        exec ${pkgs-unstable.sillytavern}/bin/sillytavern
      '';
    };
  };
}
