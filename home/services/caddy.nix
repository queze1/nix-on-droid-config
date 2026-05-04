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
    hash = "sha256-4WF7tIx8d6O/Bd0q9GhMch8lS3nlR5N3Zg4ApA3hrKw=";
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
          dns cloudflare {env.${config.age.secrets.cloudflare-api-token.path}}
        }

        sillytavern.osipol.uk {
          reverse_proxy localhost:8000
        }

        syncthing.osipol.uk {
          reverse_proxy localhost:8384
        }

        navidrome.osipol.uk {
          reverse_proxy localhost:4533
        }

        vaultwarden.osipol.uk {
          reverse_proxy localhost:8081
        }

        filebrowser.osipol.uk {
          reverse_proxy localhost:8082
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
