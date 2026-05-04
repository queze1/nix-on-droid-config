{ pkgs, ... }:
{
  home.packages = with pkgs; [
    syncthing
  ];

  services.runit.services.syncthing = {
    enable = true;
    run = ''
      exec ${pkgs.syncthing}/bin/syncthing
    '';
  };
}
