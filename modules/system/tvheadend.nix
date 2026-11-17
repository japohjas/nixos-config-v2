{ config, pkgs, username, ... }: {

  # Tvheadendin web-käyttöliittymä aukeaa selaimessasi osoitteessa 
  # http://localhost:9981 tai oman koneesi IP-osoitteella
  
  # Kun kontti on käynnissä ja viritin kytketty:
  # Avaa Tvheadend selaimessa ja mene: Configuration -> Wizard automaattiseen kanavahakuun. 
  # Valitse DVB-T2 ja alueeksi Finland: fi-All tai oma alueesi esimerkiksi Finland: fi-Isokylä. 
  # Klikkaa Next ja odota, että kanavahaku löytää kanavat.
  # 
  #
  # Kanava- ja taajuustiedot Yle HD:lle (DVB-T2) lisäysiksi Tvheadendin kanavahakuun:
  # Mene Configuration -> DVB Inputs -> Muxes.
  # Klikkaa Add.
  # Valitse luomasi DVB-T-verkko.
  # Syötä asetuksiin kommentissasi olevat tiedot:
  # 	• Frequency (kHz): 666000 (tai Hz-muodossa 666000000 riippuen siitä, kumpaa yksikköä Tvheadend pyytää)
  #	• Bandwidth: 8 MHz
  #	• Delivery system: DVB-T2
  # Tallenna, jolloin Tvheadend skannaa juuri tämän kyseisen nipun ja löytää Ylen HD-kanavat.
  
  # sudo systemctl start podman-tvheadend.service    Kontin käynnistys
  # sudo systemctl stop podman-tvheadend.service     Kontin sammutus
  # sudo systemctl restart podman-tvheadend.service  Kontin uudelleenkäynnistys
  # sudo systemctl status podman-tvheadend.service   Tilanteen ja lokien tarkistaminen
  # sudo journalctl -u podman-tvheadend.service -f   Tai lukea kontin antamia suoria lokeja
  #
  # Manuaalinen päivitys Tvheadend-kontille:
  # sudo podman pull lscr.io/linuxserver/tvheadend:latest
  # sudo systemctl try-restart podman-tvheadend.service
  # Poista vanha kuva, jos haluat säästää levytilaa: 
  # (automatisesti siivotaan myös päivityksen yhteydessä)
  # sudo podman image prune -f
  # Varmista päivityksen onnistuminen:
  # sudo podman images | grep tvheadend
  # sudo podman ps -a | grep tvheadend

  # 1. Podmanin perusasetukset
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # 2. Määritellään Tvheadend-kontti
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      tvheadend = {
        image = "lscr.io/linuxserver/tvheadend:latest";
        
        # HUOM: Jos käynnistät koneen joskus ilman USB-viritintä, vaihda tähän false,
        # true saa olla vain, jos varmistat, että viritin on kytkettynä ennen koneen käynnistystä.
        # jotta systemd ei yritä käynnistää konttia ilman /dev/dvb-laitetta.
        autoStart = false;

        ports = [
          "9981:9981" # Web-käyttöliittymä
          "9982:9982" # HTSP-striimaus
        ];

        volumes = [
          "/home/${username}/.config/tvheadend:/config"
          "/home/${username}/Videot/tvheadend-tallenteet:/recordings"
        ];

        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "Europe/Helsinki";
        };

        extraOptions = [
          "--device=/dev/dvb:/dev/dvb:rw"
          "--ipc=host"
          "--security-opt=label=disable"
        ];
      };
    };
  };

  # 3. Varmistetaan verkon valmius ennen käynnistystä
  # systemd.services.podman-tvheadend = {
  #   after = [ "network-online.target" ];
  #   wants = [ "network-online.target" ];
  # };

  # 4. Automaattinen kansioiden luonti ja oikeudet
  systemd.tmpfiles.rules = [
    "d /home/${username}/.config/tvheadend 0775 ${username} users - -"
    "d /home/${username}/Videot/tvheadend-tallenteet 0775 ${username} users - -"
  ];

  # 5. LUOTETTAVA LAITESIDONTA (udev + systemd)
  services.udev.extraRules = ''
    SUBSYSTEM=="dvb", KERNEL=="*frontend*", ACTION=="add|change", MODE="0666", TAG+="systemd", ENV{SYSTEMD_WANTS}+="podman-tvheadend.service"
  '';

  systemd.services.podman-tvheadend = {
    restartIfChanged = false;
    bindsTo = [ "dev-dvb-adapter0-frontend0.device" ];
    after = [ "network-online.target" "dev-dvb-adapter0-frontend0.device" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      # Hyväksyy Podmanin SIGTERM (143) ja SIGKILL (137) sammutuskoodit puhtaiksi,
      # jotta palvelu ei jää "failed"-tilaan tikun irrotuksen jälkeen.
      SuccessExitStatus = [ 137 143 ];
    };
  };




  # 6. Palomuurin avaukset
  networking.firewall = {
    allowedTCPPorts = [ 9981 9982 ];
    allowedUDPPorts = [ 9982 ];
  };

  # 7. Live TV -pikakuvake työpöytävalikkoon
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "livetv";
      desktopName = "Live TV";
      genericName = "Televisio";
      comment = "Katso TV-lähetyksiä Tvheadendistä MPV-soittimella";
      exec = "mpv http://localhost:9981/playlist/channels";
      # Jos olet määritellyt käyttäjätunnuksen ja salasanan Tvheadendin web-käyttöliittymään
      # exec = "mpv http://kayttaja:salasana@localhost:9981/playlist/channels";
      icon = "mpv";
      terminal = false;
      categories = [ "AudioVideo" "Video" "Player" "TV" ];
      mimeTypes = [ "x-scheme-handler/pvr" ];
    })
  ];

  # 8. NIXOS-YHTEENSOPIVA AUTOMAATTIPÄIVITYS + LOKITUS (Maanantaisin klo 16:00)
  # Helppo lokin seuranta. Kun palvelu ajetaan, kaikki echo-rivit tallentuvat 
  # suoraan journald-lokiin. Voit tarkistaa päivityshistorian milloin tahansa komennolla 
  # journalctl -u tvheadend-update.service
  #
  # Voit testata palvelun toiminnan heti nixos-rebuild switch -ajon jälkeen komennolla 
  # sudo systemctl start tvheadend-update.service && journalctl -u tvheadend-update.service -n 15
  systemd.services."tvheadend-update" = {
    description = "Päivitä Tvheadend-konttikuva, käynnistä palvelu uudelleen ja siivoa vanhat kuvat";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    path = with pkgs; [ podman systemd coreutils ];

    script = ''
      IMAGE="lscr.io/linuxserver/tvheadend:latest"
      
      echo "[Tvheadend-päivitys] Tarkistetaan päivityksiä kuvalle $IMAGE..."
      OLD_ID=$(podman images -q "$IMAGE")
      
      podman pull "$IMAGE"
      NEW_ID=$(podman images -q "$IMAGE")
      
      if [ "$OLD_ID" != "$NEW_ID" ]; then
        echo "[Tvheadend-päivitys] Uusi versio ladattu ($NEW_ID). Käynnistetään palvelu uudelleen..."
        systemctl try-restart podman-tvheadend.service
        
        echo "[Tvheadend-päivitys] Siivotaan vanhat käyttämättömät konttikuvat..."
        podman image prune -f
        echo "[Tvheadend-päivitys] Päivitys ja siivous valmis."
      else
        echo "[Tvheadend-päivitys] Kuva on jo ajan tasalla ($NEW_ID). Ei toimenpiteitä."
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
    };
  };


  systemd.timers."tvheadend-update" = {
    description = "Viikoittainen Tvheadend-päivitysajastin";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon *-*-* 16:00:00";
      Persistent = true; # Ajaa päivityksen myöhemmin, jos kone oli kiinni maanantaina klo 16
    };
  };
}
