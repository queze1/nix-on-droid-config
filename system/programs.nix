{ pkgs, ... }:
{
  environment.packages = with pkgs; [
    # Init manager
    runit

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
