{ config, pkgs, ... }: {
  
  # Aktivoidaan COSMIC työpöytäympäristö ja sen oma kirjautumisikkuna
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  
  # Aktivoidaan suorituskyvyn automaattinen optimointi (system76-scheduler)
  # CFS-profiilit (cfsProfiles) aktivoituvat tämän mukana automaattisesti taustalla.
  services.system76-scheduler.enable = true;
  
  # Järjestelmän laajuiset COSMIC-työpöytäsovellukset ja -laajennukset
  environment.systemPackages = with pkgs; [ 
    cosmic-ext-applet-external-monitor-brightness  # Ulkoisen näytön DDC/CI-kirkkaussäätö
    cosmic-ext-applet-caffeine                     # Estää näytön sammumisen / lepotilan
    
    # --- Tulevaisuutta varten valmiina odottavat resurssimonitorit ---
    # cosmic-ext-applet-minimon
    # cosmic-ext-applet-thermal-monitor
    # cosmic-ext-applet-cpu-monitor
    # cosmic-ext-applet-memory-monitor
    # cosmic-ext-applet-network-monitor
    # cosmic-ext-applet-disk-monitor
    # cosmic-ext-applet-battery-monitor # (Ei tarvita NUC-pöytäkoneella)
    ddcutil		# näytön kirkkauden säätö
  ];
  
  # Näytön kirkkauden säätö, ddcutil, DDC/CI-tuki ja oikeudet käyttöön
  # https://search.nixos.org/options?show=hardware.i2c.enable
  hardware.i2c.enable = true;
  
  #  configuration.nix 
  #  extraGroups = [ 
  #    "wheel"           # Sudo-oikeudet järjestelmän hallintaan
  #    "networkmanager"  # Oikeus hallita Wi-Fi- ja verkkoyhteyksiä
  #    "video"           # Näytönohjaimen laitteistokiihdytys & ddcutil
  #    "render"          # GPU-renderöintioikeudet (kriittinen COSMICille)
  #    "i2c"             # Ulkoisen näytön kirkkauden säätöpaneeli
  #  ];
  
  # Järjestelmänlaajuiset Ympäristömuuttujat kaikille käyttäjille ja työpöydille
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";      # Pakottaa Firefoxin natiiviin Wayland-tilaan (ei XWayland-renderöintiä)
    NIXOS_OZONE_WL = "1";          # Chromium-selaimet (Vivaldi, Chrome) natiiviin Wayland-tilaan
    GDK_BACKEND = "wayland";       # GTK-sovellukset (GIMP, Darktable, Papers) Waylandille
    QT_QPA_PLATFORM = "wayland";   # Qt/KDE-sovellukset (digiKam, KeePassXC) Waylandille ja teemoille
    XCURSOR_SIZE = "32";           # Muuta arvoa tarpeen mukaan (esim. 24 (default), 32, 48)
  };
}