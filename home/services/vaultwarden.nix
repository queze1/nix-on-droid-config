{ config, pkgs-unstable, ... }:
let
  vaultwardenDataDirectory = "${config.home.homeDirectory}/.local/share/vaultwarden";
in
{
  home.packages = with pkgs-unstable; [
    vaultwarden
  ];

  services.runit.services.vaultwarden = {
    enable = true;
    run = ''
      mkdir -p ${vaultwardenDataDirectory}
      export DATA_FOLDER="${vaultwardenDataDirectory}"
      export WEB_VAULT_FOLDER="${pkgs-unstable.vaultwarden-webvault}/share/vaultwarden/vault"
      export ROCKET_ADDRESS="0.0.0.0"
      export ROCKET_PORT="8081"
      export SIGNUPS_ALLOWED="false"
      export SHOW_PASSWORD_HINT="false"
      exec ${pkgs-unstable.vaultwarden}/bin/vaultwarden
    '';
  };
}
