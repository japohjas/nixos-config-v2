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
  ];
}