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

  cfg = config.services.filebrowser;
  filebrowserDataDirectory = "${config.home.homeDirectory}/.local/share/filebrowser";
  filebrowserDatabase = "${filebrowserDataDirectory}/filebrowser.db";
in
{
  options.services.filebrowser = {
    enable = mkEnableOption "filebrowser";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      filebrowser
    ];

    services.runit.services.filebrowser = {
      enable = true;
      run = ''
        mkdir -p ${filebrowserDataDirectory}
        exec ${pkgs.filebrowser}/bin/filebrowser \
          --address 0.0.0.0 \
          --port 8082 \
          --database "${filebrowserDatabase}" \
          --root "${config.services.navidrome.musicDirectory}"
      '';
    };
  };
}
