{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    sillytavern
  ];

  xdg.dataFile.sillytavern-config = {
    enable = true;
    target = "SillyTavern/config.yaml";
    source = ../config/sillytavern.yaml;
  };

  services.runit.services.sillytavern = {
    enable = true;
    run = ''
      exec ${pkgs-unstable.sillytavern}/bin/sillytavern
    '';
  };
}
