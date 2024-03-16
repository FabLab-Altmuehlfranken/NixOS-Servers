{ config, pkgs, ... }:
{
  imports = [
    ./atticd.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = "attic";
    domain = "fablab-altmuehlfranken.de";
  };

  system.stateVersion = "23.05";
}

