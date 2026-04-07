{ pkgs, pkgs-unstable, ... }:
{
  environment.packages = with pkgs; [
    openssh

    # Basic utilities
    iproute2
    killall
    nano
    ncurses
    procps
    which

    sillytavern
    navidrome
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
  ];
}
