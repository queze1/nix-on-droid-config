{ pkgs, config, ... }:
let
  logDirectory = "${config.user.home}/.local/var/log";
  musicDirectory = "${config.user.home}/Music";
in
{
  build.activation.sillytavern = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
    if ${pkgs.procps}/bin/pgrep -x node > /dev/null; then
      echo "Restarting SillyTavern..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q node || true
    else
      echo "Starting SillyTavern..."
    fi
    $DRY_RUN_CMD sleep 1
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.sillytavern}/bin/sillytavern >> "${logDirectory}/sillytavern.log" 2>&1 &'
  '';

  build.activation.syncthing = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
    if ${pkgs.procps}/bin/pgrep -x syncthing > /dev/null; then
      echo "Restarting Syncthing..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q syncthing || true
    else
      echo "Starting Syncthing..."
    fi
    $DRY_RUN_CMD sleep 1
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.syncthing}/bin/syncthing >> "${logDirectory}/syncthing.log" 2>&1 &'
  '';

  # build.activation.vaultwarden = ''
  #   $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
  #   if ${pkgs.procps}/bin/pgrep -x vaultwarden > /dev/null; then
  #     $VERBOSE_ECHO "Restarting Vaultwarden..."
  #     $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q vaultwarden || true
  #   else
  #     $VERBOSE_ECHO "Starting Vaultwarden..."
  #   fi

  #   # Environment variables
  #   # export DOMAIN=https://vault.example.com
  #   # export DATABASE_URL=sqlite:${config.user.home}/.local/share/vaultwarden/db.sqlite3
  #   # export ROCKET_PORT=80
  #   # export SIGNUPS_ALLOWED=false
  #   # export SHOW_PASSWORD_HINT=false
  #   $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.vaultwarden}/bin/vaultwarden >> "${logDirectory}/vaultwarden.log" 2>&1 &'
  # '';

  build.activation.navidrome = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${musicDirectory}"
    if ${pkgs.procps}/bin/pgrep -x .navidrome-wrap > /dev/null; then
      echo "Restarting Navidrome..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q .navidrome-wrap || true
    else
      echo "Starting Navidrome..."
    fi
    $DRY_RUN_CMD sleep 1
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.navidrome}/bin/navidrome --configfile "${config.user.home}/.config/navidrome.toml" >> "${logDirectory}/navidrome.log" 2>&1 &'
  '';
}
