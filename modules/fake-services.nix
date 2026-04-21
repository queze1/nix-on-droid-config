{ config, lib, ... }:

{
  options = {
    services.openssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Fake OpenSSH service.";
      };
    };

    system.build = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };

    system.activationScripts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Wrapper for build.activation.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.services.openssh.enable) {
      assertions = [
        {
          assertion = false;
          message = "services.openssh is a placeholder and cannot be enabled.";
        }
      ];
    })
    {
      # Add system.activationScripts to build.activation
      build.activation = config.system.activationScripts;
    }
  ];
}
