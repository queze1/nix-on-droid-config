{ ... }:
{
  nix.extraOptions = ''
    # Enable flakes
    experimental-features = nix-command flakes

    # Always build on remote
    # max-jobs = 0
    builders = builder aarch64-linux - 4 1 nixos-test,big-parallel,kvm
  '';
}
