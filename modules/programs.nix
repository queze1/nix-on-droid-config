{ pkgs, pkgs-unstable, ... }:
{
  environment.packages = with pkgs; [
    git
    openssh

    # Init manager
    runit

    # Basic utilities
    iproute2
    killall
    nano
    ncurses
    procps
    which

    filebrowser
    navidrome
    pkgs-unstable.sillytavern
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
    syncthing
  ];
}
