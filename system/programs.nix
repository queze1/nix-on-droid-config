{ pkgs, ... }:
{
  environment.packages = with pkgs; [
    curlMinimal
    git
    iproute2
    killall
    nano
    ncurses
    openssh
    procps
    which
  ];
}
