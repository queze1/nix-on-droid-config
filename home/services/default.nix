{ ... }:
{
  imports = [
    ./caddy.nix
    ./cloudflared.nix
    ./filebrowser.nix
    ./navidrome.nix
    ./sillytavern.nix
    ./syncthing.nix
    ./vaultwarden.nix
  ];

  services.caddy.enable = true;
  services.cloudflared.enable = false;
  services.filebrowser.enable = true;
  services.navidrome.enable = true;
  services.sillytavern.enable = true;
  services.syncthing.enable = true;
  services.vaultwarden.enable = true;
}
