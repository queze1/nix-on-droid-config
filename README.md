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

## Hosts

| Hostname | Model | Android Version | CPU | RAM | Storage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| poco-x3-pro | Xiaomi Poco X3 Pro | 12 | Octa-core Max 2.96GHz | 8 GB | 256 GB |
