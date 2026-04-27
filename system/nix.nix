{ ... }:
{
  nix.extraOptions = ''
    # Enable flakes
    experimental-features = nix-command flakes
  '';
}
