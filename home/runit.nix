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
    escapeShellArg
    optionalAttrs
    ;

  cfg = config.services.runit;
  enabledServices = lib.filterAttrs (_: s: s.enable) cfg.services;

  mkServiceFiles =
    name: svc:
    let
      serviceTarget = ".${cfg.serviceDir}/${name}";
      logTarget = ".${cfg.logDir}/${name}";
    in
    {
      "runit-${name}-run" = {
        target = "${serviceTarget}/run";
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          set -eu
          exec 2>&1
          ${svc.run}
        '';
      };
    }
    // optionalAttrs (svc.finish != "") {
      "runit-${name}-finish" = {
        target = "${serviceTarget}/finish";
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          set -eu
          ${svc.finish}
        '';
      };
    }
    // optionalAttrs svc.log.enable {
      "runit-${name}-log-run" = {
        target = "${serviceTarget}/log/run";
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          set -eu
          mkdir -p ${escapeShellArg logTarget}
          exec ${pkgs.runit}/bin/svlogd -tt ${escapeShellArg logTarget}
        '';
      };
    };
in
{
  options.services.runit = {
    enable = mkEnableOption "runit service manager";

    serviceDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/state/runit/services";
      description = "Runit service directory";
    };

    logDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/var/log/services";
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
    home.file = lib.mkMerge (mapAttrsToList mkServiceFiles enabledServices);

    home.activation.runitDirectories = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents ${escapeShellArg cfg.serviceDir}
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents ${escapeShellArg cfg.logDir}
    '';

    home.activation.runsvdir = lib.hm.dag.entryAfter [ "runitDirectories" ] ''
      export PATH=$PATH:${pkgs.runit}/bin
      if ! ${pkgs.procps}/bin/pgrep -x runsvdir > /dev/null; then
        echo "Starting runsvdir..."
        $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.runit}/bin/runsvdir ${escapeShellArg cfg.serviceDir} >> ${escapeShellArg "${cfg.logDir}/runsvdir.log"} 2>&1 &'
      fi
    '';
  };
}
