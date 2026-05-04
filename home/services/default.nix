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
}
