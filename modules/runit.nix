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
  enabledServiceNames = builtins.attrNames enabledServices;

  mkRunScript =
    name: svc:
    pkgs.writeShellScript "runit-${name}-run" ''
      set -eu
      exec 2>&1
      ${svc.run}
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
    echo "Adding runit service ${name}..."
    mkdir -p ${escapeShellArg "${cfg.serviceDir}/${name}"}
    ln -sfn ${mkRunScript name svc} ${escapeShellArg "${cfg.serviceDir}/${name}/run"}

    ${optionalString (svc.finish == "") ''
      rm -f ${escapeShellArg "${cfg.serviceDir}/${name}/finish"}
    ''}

    ${optionalString (svc.finish != "") ''
      ln -sfn ${mkFinishScript name svc} ${escapeShellArg "${cfg.serviceDir}/${name}/finish"}
    ''}

    ${optionalString (!svc.log.enable) ''
      rm -rf ${escapeShellArg "${cfg.serviceDir}/${name}/log"}
    ''}

    ${optionalString svc.log.enable ''
      mkdir -p ${escapeShellArg "${cfg.serviceDir}/${name}/log"}
      ln -sfn ${mkLogRunScript name} ${escapeShellArg "${cfg.serviceDir}/${name}/log/run"}
    ''}
  '';

in
{
  options.services.runit = {
    enable = mkEnableOption "runit service manager";

    serviceDir = mkOption {
      type = types.str;
      default = "${config.user.home}/.local/state/runit/services";
      description = "Runit service directory";
    };

    logDir = mkOption {
      type = types.str;
      default = "${config.user.home}/.local/var/log/services";
      description = "Runit log directory";
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
                description = "Runit run script.";
              };
              finish = mkOption {
                type = types.lines;
                default = "";
                description = "Optional runit finish script.";
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

      # Clean up unused services
      for path in ${escapeShellArg cfg.serviceDir}/*; do
        [ -e "$path" ] || continue
        name=$(basename "$path")
        case " ${concatStringsSep " " enabledServiceNames} " in
          *" $name "*)
            ;;
          *)
            echo "Cleaning up runit service $name..."
            $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "$path"
            $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force ${escapeShellArg cfg.logDir}/"$name"
            ;;
        esac
      done

      ${concatStringsSep "\n" (mapAttrsToList mkServiceActivation enabledServices)}
    '';

    build.activation.runsvdir = ''
      export PATH=$PATH:${pkgs.runit}/bin
      if ! ${pkgs.procps}/bin/pgrep -x runsvdir > /dev/null; then
        echo "Starting runsvdir..."
        $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.runit}/bin/runsvdir ${escapeShellArg cfg.serviceDir} >> ${escapeShellArg "${cfg.logDir}/runsvdir.log"} 2>&1 &'
      fi
    '';
  };
}
