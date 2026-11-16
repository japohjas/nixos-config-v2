    { config, pkgs, ... }: {

  # =========================================================================
  # MPV CONFIGURATION (Kevyt & Optimoitu NUC8i5BEH + Cosmic Wayland)
  # =========================================================================

  programs.mpv = {
    enable = true;

   
    config = {
      # yt-dlp integraatio (Pidetään ennallaan, erinomaiset asetukset)
      # script-opts = "ytdl_hook-ytdl_path=${config.home.profileDirectory}/bin/yt-dlp";
      # ytdl-format = "(bestvideo[height<=720]+bestaudio/best[height<=720])[vcodec!*=av01]";
      # ytdl-raw-options = "no-config,sub-langs=fin,fi,write-subs";

      # Ikkunointi
      window-maximized = "yes";
      border = "no";

      # Intel Iris Plus 655 & COSMIC Wayland -optimointi
      vo = "gpu";
      gpu-context = "wayland";
      hwdec = "auto-safe";
      
      # OPTIMOINTI: Hyödynnetään Intel EGL -rajapintaa
      gpu-api = "opengl"; 
      fbo-format = "auto";       # rgba16f on laadukas väriavaruuden käsittely GPU:lla

      # Puskurointi ja RAM-suorituskyky (Optimoitu vakaaksi myös .ts-tiedostoille)
      cache = "yes";
      demuxer-max-bytes = "150MiB";       # Pienennetty 500MiB -> 150MiB
      demuxer-max-back-bytes = "30MiB";   # Pienennetty 150MiB -> 30MiB
      # demuxer-readahead-secs = "10";      # Rajoitetaan välimuisti sekunneissa, estää kaatumiset kelatessa


      # Videon laatu ja laadukas skaalaus (Intel Iris Plus jaksaa pyörittää näitä helposti)
      scale = "spline36";           
      cscale = "spline36";          
      dscale = "mitchell";
      dither-depth = "auto";
      
      # KORJATTU: Poistettu virheellinen "no" arvo, "simple" vastaa kevyintä ditherointia
      # sierra-lite (Oletus): Nopein kohtuullisen laadun tarjoava algoritmi.
      # error-diffusion = "simple";  

      # Synkronointi cosmic-comp -ikkunointimanagerille (Nykimätön toisto)
      video-sync = "display-resample";
      interpolation = "yes";
      tscale = "oversample";

      # Tekstitykset ja kielet
      sub-auto = "all";
      sub-font = "sans-serif";
      sub-font-size = "44";
      sub-border-size = "2";
      
      # KORJATTU: Poistettu ylimääräiset sisäiset heittomerkit, suojattu vain Nixin vaatimalla tavalla
      sub-color = "#FFFFFFFF";        
      sub-border-color = "#FF000000"; 
      
      slang = "fin,fi,eng,en,swe,sv";
      alang = "fin,fi,eng,en,swe,sv";

      # DVB- ja tallennusyhteensopivuus
      save-position-on-quit = "yes";
      hr-seek = "yes";
      sub-clear-on-seek = "yes";
      dvbin-timeout = "10";  
    };

    # Pidetään näppäinkomennot ennallaan
    bindings = {
      "MBTN_MID" = "set speed 1.0";
      "WHEEL_UP" = "add speed +0.1";
      "WHEEL_DOWN" = "add speed -0.1";
      "RIGHT" = "seek 5";
      "LEFT" = "seek -5";
      "UP" = "add volume 5";
      "DOWN" = "add volume -5";
      "Shift+RIGHT" = "seek 60";
      "Shift+LEFT" = "seek -60";
      "z" = "add sub-delay -0.1"; 
      "x" = "add sub-delay +0.1"; 
      "Ctrl+8" = "add audio-delay 0.1";
      "Ctrl+9" = "add audio-delay -0.1";
      "[" = "multiply speed 1/1.1"; 
      "]" = "multiply speed 1.1";   
      "BS" = "set speed 1.0";       
      "j" = "cycle sub";
      "J" = "cycle sub down";       
      "#" = "cycle audio";
      "s" = "screenshot video";
    };
  };
}
