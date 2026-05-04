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

  cfg = config.services.cloudflared;
in
{
  options.services.cloudflared = {
    enable = mkEnableOption "cloudflared";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cloudflared
    ];

    age.secrets.cloudflare-tunnel-token = {
      file = ../../secrets/cloudflare-tunnel-token.age;
    };

    services.runit.services.cloudflared = {
      enable = true;
      run = ''
        exec ${pkgs.cloudflared}/bin/cloudflared tunnel run --protocol http2 --token-file ${config.age.secrets.cloudflare-tunnel-token.path}
      '';
      finish = ''
        sleep 5
      '';
    };
  };
}
