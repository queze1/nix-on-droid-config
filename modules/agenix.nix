{ lib, ... }:
{
  options = {
    systemd.user.services = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };

    systemd.sysusers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };

    services.openssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };

    services.userborn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = { };
}
