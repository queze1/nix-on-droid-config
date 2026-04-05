{ pkgs, config, ... }:
let
  logDirectory = "${config.user.home}/.local/var/log";
in
{
  build.activation.sillytavern = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
    if ${pkgs.procps}/bin/pgrep -x sillytavern > /dev/null; then
      $VERBOSE_ECHO "Restarting SillyTavern..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q sillytavern || true
    else
      $VERBOSE_ECHO "Starting SillyTavern..."
    fi
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.sillytavern}/bin/sillytavern >> "${logDirectory}/sillytavern.log" 2>&1 &'
  '';

  build.activation.syncthing = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${logDirectory}"
    if ${pkgs.procps}/bin/pgrep -x syncthing > /dev/null; then
      $VERBOSE_ECHO "Restarting Syncthing..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q syncthing || true
    else
      $VERBOSE_ECHO "Starting Syncthing..."
    fi
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.syncthing}/bin/syncthing >> "${logDirectory}/syncthing.log" 2>&1 &'
  '';
}
