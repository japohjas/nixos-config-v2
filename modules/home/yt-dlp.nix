{ config, pkgs, ... }: {
  
   # =========================================================================
  # YT-DLP ASETUKSET, mahdolistaa videon suoratoiston mpv kautta. mpv http//.
  # =========================================================================
  programs.yt-dlp = {
    enable = true;
  
    settings = {
      # Alentaa AV1-koodekin tärkeysjärjestystä (i5-8259U ei tue AV1-rautakiihdytystä)
      compat-options = "prefer-vp9-sort";

      # KORJATTU: Turvallinen sulkurakenne, joka ei evää pelkkää audiota ja rajaa AV1:n pois
      format = "(bestvideo[height<=720]+bestaudio/best[height<=720])[vcodec!*=av01]";
    
      # Pakotetaan tulostemuodoksi MKV tiedostotallennuksessa
      merge-output-format = "mkv";
      remux-video = "mkv";

      # Tekstitysten upottaminen tiedostoihin
      embed-subs = true;
      sub-format = "best";
      convert-subs = "srt";        

      # Valitse ladattavat kielet
      sub-langs = "fin,fi";

      # Estää ffmpeg-virheet Areena-videoiden fixup-vaiheessa
      hls-use-mpegts = true;

      # Tallennuspolku Home Managerin muuttujaa hyödyntäen
      paths = "${config.home.homeDirectory}/Videot/yt-dlp";
      output = "%(title)s [%(id)s].%(ext)s";

      # Ohita virheet soittolistoissa
      ignore-errors = true;
    };
  };
}
