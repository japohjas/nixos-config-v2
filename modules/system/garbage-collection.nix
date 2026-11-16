{ lib, pkgs, ... }: {
  
  # Siivousautomaatio
  nix.settings.auto-optimise-store = true;
  nix.gc = {
      automatic = true;
      dates = "weekly"; # Ajetaan kerran viikossa
      persistent = true;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "30min";
    };
}