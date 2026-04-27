let
  poco-x3-pro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc5qFBtTUoJyj3LGHNOEdoOlpl1jfIE/3pElxH32m54";
  utm-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y ";
in
{
  "cloudflare-tunnel-token.age" = {
    publicKeys = [
      poco-x3-pro
      utm-vm
    ];
    armor = true;
  };
}
