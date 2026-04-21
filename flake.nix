{
  description = "Advanced example of Nix-on-Droid system config with home-manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/testing";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-on-droid,
      agenix,
      ...
    }:
    {
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./nix-on-droid.nix
        ];

        # Set nixpkgs instance
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          overlays = [
            nix-on-droid.overlays.default
          ];
        };

        extraSpecialArgs = {
          inherit agenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-linux";
            overlays = [
              nix-on-droid.overlays.default
            ];
          };
        };

        # Set path to home-manager flake
        home-manager-path = home-manager.outPath;
      };
    };
}
