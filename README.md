# nix-on-droid-config
This repository contains my [nix-on-droid](https://github.com/nix-community/nix-on-droid) server configuration. It leverages [Tailscale](https://tailscale.com/) to securely connect to other devices.

## Services
- [NaviDrome](https://www.navidrome.org/) - A self-hosted, open source music server and streamer.
- [SillyTavern](https://docs.sillytavern.app/) - An open-source LLM frontend.

## Highlights
- Declarative server configuration using [flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).
- File synchronisation with [Syncthing](https://syncthing.net/).
- Remote building with Nix

## Hosts

| Hostname | Model | Android Version | CPU | RAM | Storage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| poco-x3-pro | Xiaomi Poco X3 Pro | 12 | Octa-core Max 2.96GHz | 8 GB | 256 GB |
