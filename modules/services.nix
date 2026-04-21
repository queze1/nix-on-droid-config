{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  musicDirectory = "${config.user.home}/Music";
  vaultwardenDataDirectory = "${config.user.home}/.local/share/vaultwarden";
  filebrowserDataDirectory = "${config.user.home}/.local/share/filebrowser";
  filebrowserDatabase = "${filebrowserDataDirectory}/filebrowser.db";
in
{
  services.runit = {
    enable = true;

    services.sillytavern = {
      enable = true;
      run = ''
        exec ${pkgs-unstable.sillytavern}/bin/sillytavern
      '';
    };

    services.syncthing = {
      enable = true;
      run = ''
        exec ${pkgs.syncthing}/bin/syncthing
      '';
    };

    services.vaultwarden = {
      enable = true;
      run = ''
        mkdir -p ${vaultwardenDataDirectory}
        export DATA_FOLDER="${vaultwardenDataDirectory}"
        export WEB_VAULT_FOLDER="${pkgs-unstable.vaultwarden-webvault}/share/vaultwarden/vault"
        export ROCKET_ADDRESS="0.0.0.0"
        export ROCKET_PORT="8080"
        export SIGNUPS_ALLOWED="false"
        export SHOW_PASSWORD_HINT="false"
        exec ${pkgs-unstable.vaultwarden}/bin/vaultwarden
      '';
    };

    services.navidrome = {
      enable = true;
      run = ''
        mkdir -p ${musicDirectory}
        exec ${pkgs.navidrome}/bin/navidrome --configfile "${config.user.home}/.config/navidrome.toml"
      '';
    };

    services.filebrowser = {
      enable = true;
      run = ''
        mkdir -p ${filebrowserDataDirectory}
        exec ${pkgs.filebrowser}/bin/filebrowser \
          --address 0.0.0.0 \
          --port 8081 \
          --database "${filebrowserDatabase}" \
          --root "${musicDirectory}"
      '';
    };
  };
}
