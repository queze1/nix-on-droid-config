{ pkgs, ... }:
{
  environment.packages = with pkgs; [
    openssh

    # Basic utilities
    iproute2
    nano
    ncurses
    which

    sillytavern
    vaultwarden
  ];
}
