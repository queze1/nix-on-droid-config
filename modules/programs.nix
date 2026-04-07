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
    pkgs-unstable.vaultwarden
    pkgs-unstable.vaultwarden-webvault
  ];
}
