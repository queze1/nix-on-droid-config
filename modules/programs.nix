{ pkgs, pkgs-unstable, ... }:
{
  environment.packages = with pkgs; [
    # Init manager
    runit

    # Basic utilities
    curlMinimal
    git
    iproute2
    killall
    nano
    ncurses
    openssh
    procps
    which

    # Services
    caddy
    filebrowser
    navidrome
    pkgs-unstable.sillytavern
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
    syncthing
  ];
}
