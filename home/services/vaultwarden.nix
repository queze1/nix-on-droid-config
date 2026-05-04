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
    mkOption
    types
    ;

  cfg = config.services.vaultwarden;
in
{
  options.services.vaultwarden = {
    enable = mkEnableOption "vaultwarden";

    dataDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/share/vaultwarden";
      description = "Directory for Vaultwarden data.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs-unstable; [ vaultwarden ];

    services.runit.services.vaultwarden = {
      enable = true;
      run = ''
        mkdir -p ${cfg.dataDirectory}
        export DATA_FOLDER="${cfg.dataDirectory}"
        export WEB_VAULT_FOLDER="${pkgs-unstable.vaultwarden-webvault}/share/vaultwarden/vault"
        export ROCKET_ADDRESS="0.0.0.0"
        export ROCKET_PORT="8081"
        export SIGNUPS_ALLOWED="false"
        export SHOW_PASSWORD_HINT="false"
        exec ${pkgs-unstable.vaultwarden}/bin/vaultwarden
      '';
    };
  };
}
