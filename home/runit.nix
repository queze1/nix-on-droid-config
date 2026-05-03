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

  # runit-manager = pkgs.writeShellScriptBin "runit-manager" ''
  #   set -eu
  #   service_dir=${escapeShellArg cfg.serviceDir}
  #   log_file=${escapeShellArg "${cfg.logDir}/runsvdir.log"}

  #   case "''${1:-}" in
  #     start)
  #       if ! pgrep -x runsvdir >/dev/null; then
  #         setsid runsvdir "$service_dir" > "$log_file" 2>&1 &
  #         echo "runsvdir started"
  #       else
  #         echo "runsvdir already running"
  #       fi
  #       ;;
  #     stop)
  #       if pgrep -x runsvdir >/dev/null; then
  #         pkill -HUP -x runsvdir
  #         echo "runsvdir sent HUP"
  #       else
  #         echo "runsvdir not running"
  #       fi
  #       ;;
  #     status)
  #       if pgrep -x runsvdir >/dev/null; then
  #         echo "runsvdir running"
  #       else
  #         echo "runsvdir not running"
  #       fi
  #       ;;
  #     *)
  #       echo "usage: $0 {start|stop|status}"
  #       exit 1
  #       ;;
  #   esac
  # '';

  mkServiceFiles =
    name: svc:
    let
      serviceTarget = "${cfg.serviceDir}/${name}";
      logTarget = "${cfg.logDir}/${name}";
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
        force = true;
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
        force = true;
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
        force = true;
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

    home.shellAliases = {
      "cd-service-dir" = "cd ${config.services.runit.serviceDir}";
      "cd-log-dir" = "cd ${config.services.runit.logDir}";
    };

    # home.packages = [ runit-manager ];

    home.activation.runitDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run --quiet mkdir --parents ${escapeShellArg cfg.serviceDir}
      run --quiet mkdir --parents ${escapeShellArg cfg.logDir}
    '';

    home.activation.runitCleanup = lib.hm.dag.entryAfter [ "runitDirectories" ] ''
      service_dir=${escapeShellArg cfg.serviceDir}
      enabled_names="${lib.concatStringsSep " " (builtins.attrNames enabledServices)}"

      if [ -d "$service_dir" ]; then
        for dir in "$service_dir"/*; do
          [ -d "$dir" ] || continue
          name=$(basename "$dir")
          case " $enabled_names " in
            *" $name "*) ;;
            *)
              run rm -rf "$dir"
              ;;
          esac
        done
      fi
    '';

    home.activation.runsvdir = lib.hm.dag.entryAfter [ "runitCleanup" "installPackages" ] ''
      if ! ${pkgs.procps}/bin/pgrep -x runsvdir > /dev/null; then
        echo "Starting runsvdir..."
        run ${pkgs.util-linux}/bin/setsid ${pkgs.runit}/bin/runsvdir ${escapeShellArg cfg.serviceDir} \
            > ${escapeShellArg "${cfg.logDir}/runsvdir.log"} 2>&1 &
      fi
    '';
  };
}
