{ pkgs, ... }:
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
    vaultwarden
    vaultwarden-webvault
  ];
}
