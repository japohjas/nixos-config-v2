    { config, pkgs, ... }: {

  # =========================================================================
  # MPV CONFIGURATION (Kevyt & Optimoitu toshiba-kannettavalle)
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

      # Grafiikkarajapinta ja ulostulo
      vo = "gpu";
      # gpu-context = "wayland";
      hwdec = "auto-safe";
      
      # OPTIMOINTI: Hyödynnetään Intel EGL -rajapintaa
      gpu-api = "opengl"; 
      
      # Puskurointi (Pieni RAM/välimuisti estää prosessorin tukehtumisen)
      cache = "yes";
      demuxer-max-bytes = "50MiB";       # Pienennetty 500MiB -> 150MiB
      demuxer-max-back-bytes = "10MiB";   # Pienennetty 150MiB -> 30MiB
      # demuxer-readahead-secs = "10";      # Rajoitetaan välimuisti sekunneissa, estää kaatumiset kelatessa

      # Videon laatu ja laadukas skaalaus (Intel Iris Plus jaksaa pyörittää näitä helposti)
      # Aggressiivinen suorituskyvyn säästö (Poistaa nykimistä heikolla suorittimella)
      profile="fast";            # Kytkee pois kaikki raskaat MPV-käsittelyt
      sws-fast="yes";            # Pakottaa erittäin kevyen ohjelmistoskaalauksen
      vd-lavc-fast="yes";        # Nopeuttaa koodekkien purkua laadun kustannuksella
      vd-lavc-skiploopfilter="nonkey"; # Jättää väliin raskaita renderöintivaiheita (estää pätkimistä)
      
      # Synkronointi (Yksinkertaistettu – ei interpolationia tai display-resamplea)
      video-sync="audio";        # Synkronoi videon ääneen (kevein tila prosessorille)

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
    # Hiiren painikkeet
    # MBTN_LEFT        cycle pause         # Vasen klikkaus: Tauota / Jatka videota
    # MBTN_RIGHT       ignore              # Oikea klikkaus: Ei tee mitään
    # MBTN_MID         set speed 1.0       # Rullaklikkaus: Palauttaa toistonopeuden normaaliksi (1.0x)
    # Hiiren rulla (Pelkkä rulla = Toistonopeus)
    # WHEEL_UP         add speed +0.1      # Rulla ylös: Nopeuttaa toistoa
    # WHEEL_DOWN       add speed -0.1      # Rulla alas: Hidastaa toistoa    
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
