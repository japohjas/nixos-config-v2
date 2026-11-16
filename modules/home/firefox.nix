{ config, pkgs, ... }: {
  
  programs.firefox = {
    enable = true;
    
    # testaus: $ nix-shell -p intel-gpu-tools --run "sudo intel_gpu_top"
    
    # Pakollinen polkumääritys Home Manager standalone -asennuksille unstable-haarassa
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    
    # Selainlaajennusten hallinta (Järjestelmätason pakotetut käytännöt)
    policies = {
      DisableTelemetry = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
      };
    };

    # Profiiliasetukset
    profiles.default = {
      isDefault = true;
      id = 0;
      name = "default";
      
      settings = {
        # === COSMIC & TYÖPÖYTÄINTEGRAATIO ===
        "widget.gtk.libadwaita-colors.enabled" = false;
        "browser.display.os-zoom-behavior" = 0; 
        
        # TURVALLISUUS: Pakotetaan Firefox käyttämään COSMICissa asennettua GNOME Keyringiä (libsecret)
        "signon.systemKeyring.enabled" = true;

        # === GRAFIIKKA JA WAYLAND (Iris Plus 655) ===
        "gfx.webrender.all" = true;
        "gfx.webrender.precache-shaders" = true; # Esikääntää shaderit 1440p-ruudulle (poistaa mikronykimisen)
        "widget.dmabuf.force-enabled" = true;   
        "widget.wayland.vsync.enabled" = true;  

        # === VA-API VIDEONRAUDAN PURKU ===
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "media.rdd-vpx.enabled" = false;
        "media.rdd-process.enabled" = false;
        "media.ffvpx.enabled" = false;
        "media.navigator.mediadatadecoder_vpx_enabled" = true; 
        "media.av1.enabled" = false; # Iris 655 ei tue AV1-rautapurkua
      };
    };
  };
}
