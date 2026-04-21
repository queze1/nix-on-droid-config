{ ... }:
{
  imports = [
    ./fake-services.nix
    ./nix.nix
    ./programs.nix
    ./runit.nix
    ./services.nix
    ./sshd.nix
  ];
}
