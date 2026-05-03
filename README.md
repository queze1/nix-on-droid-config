# nix-on-droid-config
This repository contains my [nix-on-droid](https://github.com/nix-community/nix-on-droid) server configuration. It uses [Tailscale](https://tailscale.com/) to securely connect to other devices.

## Services
- [VaultWarden](https://github.com/dani-garcia/vaultwarden) - A self-hosted, open-source password manager.
- [NaviDrome](https://www.navidrome.org/) - A self-hosted, open source music server and streamer.
- [SillyTavern](https://docs.sillytavern.app/) - An open-source LLM frontend.
- [File Browser](https://filebrowser.org/) - A web file manager.

## Highlights
- Service management with [runit](https://smarden.org/runit/).
- Declarative server configuration using [flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).
- File synchronisation with [Syncthing](https://syncthing.net/).
- Secret management with [agenix](https://github.com/ryantm/agenix).

## Installation


1. Install [Nix-on-Droid](https://github.com/nix-community/nix-on-droid) on an Android device. Set up with flakes (may take 20-30 minutes).
Optional but highly recommended:
2. Install [Tailscale](https://tailscale.com/) on your device and where you will be SSHing into the device. (optional but highly recommended)
3. On the device:
```bash
cd ~/.config/nix-on-droid

vi nix-on-droid.nix
# Use vi to add git-minimal to environment.packages
# Optional: Add iproute2 (to get IP address), nano (alternative text editor)
nix-on-droid switch

# If you are forking, don't forget to update these files
# system/sshd.nix: Add your SSH public key
# secrets/*: Configure your agenix secrets
# nix-on-droid.nix: Update user.gid and user.uid with the results of `id nix-on-droid` on your device

cd ..
git clone https://github.com/queze1/nix-on-droid-config.git  # or your fork
cd nix-on-droid-config
nix-on-droid switch  # may take an hour or more for the first time
```
4. Test if SSH has been configured correctly:
```
# Use Tailscale DNS or get your device's IP address with `ip addr`
ssh -p 8022 nix-on-droid@YOUR_PHONE
```
5. Optional: Set up remote deployment with [deploy-rs](https://github.com/serokell/deploy-rs). ([guide](https://github.com/nix-community/nix-on-droid/wiki/Remote-deploy-with-deploy%E2%80%90rs))
  - Without remote deployment, updating `nixpkgs` can take around 30 minutes in evaluation time (depending on phone specs).

## Hosts

| Hostname | Model | Android Version | CPU | RAM | Storage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| poco-x3-pro | Xiaomi Poco X3 Pro | 12 | Octa-core Max 2.96GHz | 8 GB | 256 GB |

