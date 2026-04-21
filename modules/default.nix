{ ... }:
{
  imports = [
    ./agenix-activation.nix
    ./nix.nix
    ./programs.nix
    ./runit.nix
    ./services.nix
    ./sshd.nix
  ];
}
