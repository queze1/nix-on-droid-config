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

  cfg = config.services.caddy;

  caddyPkg = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/caddy-dns/cloudflare@v0.2.4"
    ];
    hash = "sha256-uKtStb6m1/hA5IaAdIyLGzAQdyIySjISdxXIRxehhyI=";
  };
in
{
  options.services.caddy = {
    enable = mkEnableOption "caddy";
  };

  config = mkIf cfg.enable {
    home.packages = [ caddyPkg ];

    age.secrets.cloudflare-api-token = {
      file = ../../secrets/cloudflare-api-token.age;
    };

    xdg.configFile.caddyfile = {
      enable = true;
      target = "Caddyfile";
      text = ''
        {
          http_port  8080
          https_port 8443
          acme_dns cloudflare {file.${config.age.secrets.cloudflare-api-token.path}}
        }

        sillytavern.osipol.uk {
          @tailscale remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
          handle @tailscale {
            reverse_proxy localhost:8000
          }
          respond "Forbidden" 403
        }

        navidrome.osipol.uk {
          @tailscale remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
          handle @tailscale {
            reverse_proxy localhost:4533
          }
          respond "Forbidden" 403
        }

        vaultwarden.osipol.uk {
          @tailscale remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
          handle @tailscale {
            reverse_proxy localhost:8081
          }
          respond "Forbidden" 403
        }

        filebrowser.osipol.uk {
          @tailscale remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
          handle @tailscale {
            reverse_proxy localhost:8082
          }
          respond "Forbidden" 403
        }
      '';
    };

    services.runit.services.caddy = {
      enable = true;
      run = ''
        exec ${caddyPkg}/bin/caddy run --config ${config.home.homeDirectory}/.config/Caddyfile
      '';
    };
  };
}
