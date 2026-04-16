{ pkgs, config, ... }:
let
  sshdDirectory = "${config.user.home}/sshd";
  pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y andrewh@utm-vm";
  port = 8022;
in
{
  build.activation.sshd = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    $DRY_RUN_CMD echo ${pubKey} > "${config.user.home}/.ssh/authorized_keys"
    $DRY_RUN_CMD chmod $VERBOSE_ARG 700 "${config.user.home}/.ssh"
    $DRY_RUN_CMD chmod $VERBOSE_ARG 600 "${config.user.home}/.ssh/authorized_keys"

    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.local/var/log"
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdDirectory}"

    if [[ ! -f "${sshdDirectory}/ssh_host_ed25519_key" ]]; then
      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "${sshdDirectory}/ssh_host_ed25519_key" -N ""
    fi

    $VERBOSE_ECHO "Writing sshd_config..."
    $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_ed25519_key\nPort ${toString port}\nPubkeyAuthentication yes\nAuthenticationMethods publickey\nAuthorizedKeysFile ${config.user.home}/.ssh/authorized_keys\nStrictModes no\nPasswordAuthentication no\nKbdInteractiveAuthentication no\nChallengeResponseAuthentication no\nUsePAM no\nPermitUserEnvironment yes\n" > "${sshdDirectory}/sshd_config"

    # Kill any existing sshd processes
    if ${pkgs.procps}/bin/pgrep -x sshd > /dev/null; then
      $VERBOSE_ECHO "Restarting sshd..."
      $DRY_RUN_CMD ${pkgs.killall}/bin/killall -q sshd || true
    else
      $VERBOSE_ECHO "Starting sshd..."
    fi

    # Start sshd in the background
    $DRY_RUN_CMD ${pkgs.runtimeShell} -lc 'nohup ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D >> "${config.user.home}/.local/var/log/sshd.log" 2>&1 &'
  '';

  environment.packages = [
    (pkgs.writeScriptBin "sshd-start" ''
      #!${pkgs.runtimeShell}

      echo "Starting sshd in non-daemonized way on port ${toString port}"
      ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
    '')
  ];
}
