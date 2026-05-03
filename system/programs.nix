{ pkgs, ... }:
{
  environment.packages = with pkgs; [
    # Init manager
    runit

    # System utils
    curl
    findutils
    git
    iproute2
    nano
    ncurses
    openssh
    procps
    psmisc
    util-linux
    which

    # CLI tools
    htop
  ];
}
