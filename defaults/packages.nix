{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    btop
    screen
  ];
}
