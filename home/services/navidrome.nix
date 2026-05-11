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
    mkOption
    types
    ;

  cfg = config.services.navidrome;
in
{
  options.services.navidrome = {
    enable = mkEnableOption "navidrome";

    musicDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Music";
      description = "Directory for Navidrome music files.";
    };

    dataDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/share/navidrome";
      description = "Directory for Navidrome data.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ navidrome ];

    xdg.configFile.navidrome-config = {
      enable = true;
      target = "navidrome/config.toml";
      text = ''
        MusicFolder = "${cfg.musicDirectory}"
        DataFolder = "${cfg.dataDirectory}"
        Address = "127.0.0.1"
        Port = 4533

        # Scan every hour
        Scanner.Schedule = "0 * * * *"
      '';
    };

    services.runit.services.navidrome = {
      enable = true;
      run = ''
        mkdir -p ${cfg.musicDirectory}
        exec ${pkgs.navidrome}/bin/navidrome --configfile "${config.home.homeDirectory}/.config/navidrome/config.toml"
      '';
    };
  };
}
