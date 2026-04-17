# 1. Create shell scripts in Nix store
# 2. Create directories and symlink shell scripts to them
# 3. Run runsvdir on it

{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    mapAttrsToList
    concatStringsSep
    escapeShellArg
    optionalString
    ;

  cfg = config.services.runit;
  enabledServices = lib.filterAttrs (_: s: s.enable) cfg.services;

  mkRunScript =
    name: svc:
    pkgs.writeShellScript "runit-${name}-run" ''
      set -eu
      exec 2>&1
      exec ${svc.run}
    '';

  mkFinishScript =
    name: svc:
    pkgs.writeShellScript "runit-${name}-finish" ''
      set -eu
      ${svc.finish}
    '';

  mkLogRunScript =
    name:
    pkgs.writeShellScript "runit-${name}-log-run" ''
      set -eu
      mkdir -p ${escapeShellArg "${cfg.logDir}/${name}"}
      exec ${pkgs.runit}/bin/svlogd -tt ${escapeShellArg "${cfg.logDir}/${name}"}
    '';

  mkServiceActivation = name: svc: ''
    mkdir -p ${escapeShellArg "${cfg.serviceDir}/${name}"}
    ln -sfn ${mkRunScript name svc} ${escapeShellArg "${cfg.serviceDir}/${name}/run"}
    chmod +x ${escapeShellArg "${cfg.serviceDir}/${name}/run"}

    ${optionalString (svc.finish != "") ''
      ln -sfn ${mkFinishScript name svc} ${escapeShellArg "${cfg.serviceDir}/${name}/finish"}
      chmod +x ${escapeShellArg "${cfg.serviceDir}/${name}/finish"}
    ''}

    ${optionalString svc.log.enable ''
      mkdir -p ${escapeShellArg "${cfg.serviceDir}/${name}/log"}
      ln -sfn ${mkLogRunScript name} ${escapeShellArg "${cfg.serviceDir}/${name}/log/run"}
      chmod +x ${escapeShellArg "${cfg.serviceDir}/${name}/log/run"}
    ''}
  '';

in
{
  options.services.runit = {
    enable = mkEnableOption "runit service manager";

    serviceDir = mkOption {
      type = types.str;
      default = "${config.user.home}/.local/state/runit/services";
      description = "Writable runit service directory watched by runsvdir.";
    };

    logDir = mkOption {
      type = types.str;
      default = "${config.user.home}/.local/var/log/services";
      description = "Root directory for svlogd per-service logs.";
    };

    services = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkOption {
                type = types.bool;
                default = true;
              };
              run = mkOption {
                type = types.lines;
                description = "Command/script body executed by runit run script.";
              };
              finish = mkOption {
                type = types.lines;
                default = "";
                description = "Optional finish script body.";
              };
              log.enable = mkOption {
                type = types.bool;
                default = true;
              };
            };
          }
        )
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    build.activation.runitServices = ''
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents ${escapeShellArg cfg.serviceDir}
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents ${escapeShellArg cfg.logDir}

      ${concatStringsSep "\n" (mapAttrsToList mkServiceActivation enabledServices)}
    '';

    build.activation.runsvdir = ''
      if ! ${pkgs.procps}/bin/pgrep -x runsvdir > /dev/null; then
        echo "Starting runsvdir..."
        $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.runit}/bin/runsvdir ${escapeShellArg cfg.serviceDir} >> ${escapeShellArg "${cfg.logDir}/runsvdir.log"} 2>&1 &'
      fi
    '';
  };
}
