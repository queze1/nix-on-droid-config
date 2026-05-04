{ config, pkgs, ... }:
let
  musicDirectory = "${config.home.homeDirectory}/Music";
  dataDirectory = "${config.home.homeDirectory}/.local/share/navidrome";
in
{
  config = {
    home.packages = with pkgs; [
      navidrome
    ];

    xdg.dataFile.navidrome-config = {
      enable = true;
      target = "navidrome/config.yaml";
      text = ''
        MusicFolder = "${musicDirectory}"
        DataFolder = "${dataDirectory}"
        Address = "0.0.0.0"
        Port = 4533
      '';
    };

    services.runit.services.navidrome = {
      enable = true;
      run = ''
        mkdir -p ${musicDirectory}
        exec ${pkgs.navidrome}/bin/navidrome --configfile "${config.home.homeDirectory}/.config/navidrome.toml"
      '';
    };
  };
}
