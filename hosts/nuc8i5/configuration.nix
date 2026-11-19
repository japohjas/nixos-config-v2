# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# 13.02.2026 

{ config, pkgs, username, hostname, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system/cosmic-desktop.nix
      ../../modules/system/zram-tmp.nix
      # ../../modules/system/intel-nuc8i5.nix  # nixos-hardware flake.nix
      ../../modules/system/backup-ext4.nix
      ../../modules/system/garbage-collection.nix
      ../../modules/system/pctv-firmware.nix
      ../../modules/system/fonts.nix
      ../../modules/system/tvheadend.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.configurationLimit = 10;
  
  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fi";
    variant = "";
  };

  # Configure console keymap
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fi";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    description = "Käyttäjä ${username} koneella ${hostname}";
    extraGroups = [ 
      "wheel"           # Sudo-oikeudet järjestelmän hallintaan
      "networkmanager"  # Oikeus hallita Wi-Fi- ja verkkoyhteyksiä
      "video"           # Näytönohjaimen laitteistokiihdytys & ddcutil
      "render"          # GPU-renderöintioikeudet (kriittinen COSMICille)
      "i2c"             # Ulkoisen näytön kirkkauden säätöpaneeli
    ];
  };
  
  # Install firefox. modules/home/firefox.nix sisältää Firefoxin asennuksen ja määritykset.
  # programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    # git
    # libreelec-dvb-firmware	# digitv-ajuri
  ];
  
  environment.variables.EDITOR = "vim";
  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # services.blueman.enable = true;
  # services.fstrim.enable = true; # btrfs.nix sisältää jo fstrim:n automaattisen ajon

  # digikam-ajuri (libgphoto2) ja oikeudet käyttöön, rigoh gr3x. Ei tarvita
  # Ota käyttöön Gnome Virtual File System, joka hoitaa MTP-liitännät taustalla
  # services.gvfs.enable = true;
  # Lataa libgphoto2-paketin udev-säännöt kameroiden tunnistusta varten
  # services.udev.packages = [ pkgs.libgphoto2 ];


  # https://nixos.wiki/wiki/Fwupd
  services.fwupd.enable = true;

  services.flatpak.enable = true;
  
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
