{ config, pkgs, ... }:
let
  filebrowserDataDirectory = "${config.home.homeDirectory}/.local/share/filebrowser";
  filebrowserDatabase = "${filebrowserDataDirectory}/filebrowser.db";
  musicDirectory = "${config.home.homeDirectory}/Music";
in
{
  home.packages = with pkgs; [
    filebrowser
  ];

  services.runit.services.navidrome = {
    enable = true;
    run = ''
      mkdir -p ${filebrowserDataDirectory}
      exec ${pkgs.filebrowser}/bin/filebrowser \
        --address 0.0.0.0 \
        --port 8082 \
        --database "${filebrowserDatabase}" \
        --root "${musicDirectory}"
    '';
  };
}
