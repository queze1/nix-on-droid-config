{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  logDirectory = "${config.user.home}/.local/var/log";
  musicDirectory = "${config.user.home}/Music";
  vaultwardenDataDirectory = "${config.user.home}/.local/share/vaultwarden";
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
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs-unstable.sillytavern}/bin/sillytavern >> "${logDirectory}/sillytavern.log" 2>&1 &'
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

  build.activation.vaultwarden = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${vaultwardenDataDirectory}"
    if ${pkgs.procps}/bin/pgrep -x vaultwarden > /dev/null; then
      echo "Restarting Vaultwarden..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q vaultwarden || true
    else
      echo "Starting Vaultwarden..."
    fi
    $DRY_RUN_CMD sleep 1
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc '
      export DATA_FOLDER="${vaultwardenDataDirectory}"
      export WEB_VAULT_FOLDER="${pkgs-unstable.vaultwarden-webvault}/share/vaultwarden/vault"
      export ROCKET_ADDRESS="0.0.0.0"
      export ROCKET_PORT="8080"
      export SIGNUPS_ALLOWED="false"
      export SHOW_PASSWORD_HINT="false"
      nohup ${pkgs-unstable.vaultwarden}/bin/vaultwarden >> "${logDirectory}/vaultwarden.log" 2>&1 &'
  '';

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
