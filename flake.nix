{
  description = "NixOS flake + home-manager + lanzaboote + nixos-hardware";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";

      mkHost = {
        hostname,
        username,
        diskuuid ? "",
        stateVersion ? "26.05",
        secureBoot ? false,
        hardwareModules ? [],
        homeModules
      }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostname username diskuuid stateVersion secureBoot; };
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
          
          # Lanzaboote / Secure Boot
          ({ lib, pkgs, ... }: lib.mkIf secureBoot {
            environment.systemPackages = [ pkgs.sbctl ];
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
              configurationLimit = 10;
            };
          })

          # Home Manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs hostname username diskuuid stateVersion secureBoot; };
            home-manager.users.${username} = {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = stateVersion;
              programs.home-manager.enable = true;
              imports = [ ./users/${username}/home.nix ] ++ homeModules; # home-moduulit lisätään käyttäjäkohtaisiin asetuksiin
            };
          }
        ] ++ hardwareModules; # Lisätään laitteistoprofiilit moduulilistaan
      };
    in
    {
      nixosConfigurations = {
        nuc8i5 = mkHost {
          hostname = "nuc8i5";
          username = "jari";
          diskuuid = "b98a7ceb-2b22-42f5-8e0d-078810b7fee9"; # Varmuuskopiolevyn UUID
          stateVersion = "25.11"; # Asennusajankohta / yhteensopivuusversio,
          secureBoot = false; # true
          hardwareModules = [
            nixos-hardware.nixosModules.intel-nuc-8i7beh
          ];
          homeModules = [
            ./modules/home/chromium.nix
            ./modules/home/firefox.nix
            # ./modules/home/vivaldi.nix
            ./modules/home/gimp.nix
            ./modules/home/git.nix
            ./modules/home/mpv.nix
            ./modules/home/vscode.nix
            ./modules/home/yt-dlp.nix
          ];
        };

        toshiba-l300 = mkHost {
          hostname = "toshiba-l300";
          username = "helmi";
          diskuuid = "c732283f-0ac9-4ce8-83cb-bb9f71198518"; # Varmuuskopiolevyn UUID
          stateVersion = "26.05";  # Asennusajankohta / yhteensopivuusversio,
          secureBoot = false;
          hardwareModules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
          ];
          homeModules = [
            ./modules/home/mpv-fast.nix
          ];
        };
      };
    };
}
