{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    cloudflared
  ];

  age.secrets.cloudflare-tunnel-token = {
    file = ../../secrets/cloudflare-tunnel-token.age;
  };

  services.runit.services.cloudflared = {
    enable = false;
    run = ''
      exec ${pkgs.cloudflared}/bin/cloudflared tunnel run --protocol http2 --token-file ${config.age.secrets.cloudflare-tunnel-token.path}
    '';
    finish = ''
      sleep 5
    '';
  };
}
