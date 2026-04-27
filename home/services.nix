{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  musicDirectory = "${config.home.homeDirectory}/Music";
  vaultwardenDataDirectory = "${config.home.homeDirectory}/.local/share/vaultwarden";
  filebrowserDataDirectory = "${config.home.homeDirectory}/.local/share/filebrowser";
  filebrowserDatabase = "${filebrowserDataDirectory}/filebrowser.db";
in
{
  home.packages = with pkgs; [
    caddy
    cloudflared
    filebrowser
    navidrome
    pkgs-unstable.sillytavern
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
    syncthing
  ];

  services.runit = {
    enable = true;

    services.caddy = {
      enable = true;
      run = ''
        exec ${pkgs.caddy}/bin/caddy run ${../config/Caddyfile}
      '';
    };

    services.cloudflared = {
      enable = true;
      run = ''
        exec ${pkgs.cloudflared}/bin/cloudflared tunnel run --token-file ${config.age.secrets.cloudflare-tunnel-token.path}
      '';
      finish = ''
        sleep 5
      '';
    };

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
        exec ${pkgs.navidrome}/bin/navidrome --configfile "${config.home.homeDirectory}/.config/navidrome.toml"
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
