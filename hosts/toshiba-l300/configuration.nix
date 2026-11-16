# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, username, hostname, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./btrfs-boot-bios.nix
      # ./libreoffice-s.nix
      ../../modules/system/pctv-firmware.nix
      ../../modules/system/garbage-collection.nix
      ../../modules/btrfs/btrfs.nix
      ../../modules/btrfs/tvheadend-btrfs.nix
      ../../modules/btrfs/btrbk-v2.nix
    ];

   # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;
  # Use provided UUIDs instead of blkid probing (required for btrfs subvolumes)
  boot.loader.grub.fsIdentifier = "provided";
  boot.loader.grub.configurationLimit = 10;

  networking.hostName = hostname; # Define your hostname.

  # networking.hostName = "nixos"; # Define your hostname.
  
    # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fi";
    # useXkbConfig = true; # use xkb.options in tty.
  };
  
  services.xserver.xkb = {
    layout = "fi";
    variant = "";
  };
  
  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Kansioiden päivittäminen suomeksi:
  # LC_ALL=fi_FI.UTF-8 xdg-user-dirs-update --force
  # Oikeudet
  # chmod -R 755 kansion_nimi
  # chown <username>:users tiedosto
  # Vanhat kansiot roskakoriin, tiedostojen siirron jälkeen.

  # Select internationalisation properties.
  i18n.defaultLocale = "fi_FI.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  }; 
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
 users.users."${username}" = {
    isNormalUser = true;
    description = "Käyttäjä ${username} koneella ${hostname}";
    extraGroups = [ 
      "wheel"           # Sudo-oikeudet järjestelmän hallintaan
      "networkmanager"  # NetworkManager-oikeudet
      "video"           # Video-oikeudet (esim. vaapi)
      "audio"           # Audio-oikeudet (esim. pipewire)
    ];
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  programs.firefox.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    xfce4-pulseaudio-plugin
    xfce4-whiskermenu-plugin
    networkmanagerapplet
    git
    chromium
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # nixos-hardware flake.nix
  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = [
  #     pkgs.intel-vaapi-driver
  #   ];
  # };

  # boot.initrd.kernelModules = [ "i915" ];
  
  environment.variables = {
    #toshiba intel 585
    GALLIUM_DRIVER = "llvmpipe";
    WGPU_BACKEND = "gl";
    # wayland
    # NIXOS_OZONE_WL = "1";
    # vaapi
    LIBVA_DRIVER_NAME = "i965";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

