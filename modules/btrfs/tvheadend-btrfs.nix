# =====================================================================
# TVHEADEND & PODMAN KONFIGURAATIO
# =====================================================================

{ config, pkgs, username, ... }: {

  # Tvheadendin web-käyttöliittymä aukeaa selaimessasi osoitteessa 
  # http://localhost:9981 tai oman koneesi IP-osoitteella
  
  # Kun kontti on käynnissä ja viritin kytketty:
  # Avaa Tvheadend selaimessa ja mene: Configuration -> Wizard automaattiseen kanavahakuun. 
  # Valitse DVB-T2 ja alueeksi Finland: fi-All tai oma alueesi esimerkiksi Finland: fi-Isokylä. 
  # Klikkaa Next ja odota, että kanavahaku löytää kanavat.
  # 
  # Kanava- ja taajuustiedot Yle HD:lle (DVB-T2) lisäysiksi Tvheadendin kanavahakuun:
  # Mene Configuration -> DVB Inputs -> Muxes.
  # Klikkaa Add.
  # Valitse luomasi DVB-T-verkko.
  # Syötä asetuksiin tiedot:
  #   • Frequency (kHz): 666000 (tai Hz-muodossa 666000000)
  #   • Bandwidth: 8 MHz
  #   • Delivery system: DVB-T2
  # Tallenna, jolloin Tvheadend skannaa nipun ja löytää Ylen HD-kanavat.
  
  # sudo systemctl start podman-tvheadend.service    Kontin käynnistys
  # sudo systemctl stop podman-tvheadend.service     Kontin sammutus
  # sudo systemctl restart podman-tvheadend.service  Kontin uudelleenkäynnistys
  # sudo systemctl status podman-tvheadend.service   Tilanteen ja lokien tarkistaminen
  # sudo journalctl -u podman-tvheadend.service -f   Suorien lokien seuranta
  #
  # Manuaalinen päivitys Tvheadend-kontille:
  # sudo podman pull lscr.io/linuxserver/tvheadend:latest
  # sudo systemctl try-restart podman-tvheadend.service
  # sudo podman image prune -f

  # 1. Podmanin perusasetukset + Btrfs-tallennusajuri
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Käytetään Btrfs:n natiiveja alitaltioita konttien levykerroksille
  # (NixOS asettaa oikeat rootful/rootless-polut automaattisesti ilman varoituksia)
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "btrfs";
    };
  };

  # 2. Määritellään Tvheadend-kontti
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      tvheadend = {
        image = "lscr.io/linuxserver/tvheadend:latest";
        
        # Pidä false-arvossa: udev ja systemd käynnistävät kontin automaattisesti,
        # kun DVB-viritin havaitaan järjestelmässä.
        autoStart = false;

        ports = [
          "9981:9981" # Web-käyttöliittymä
          "9982:9982" # HTSP-striimaus
        ];

        volumes = [
          "/home/${username}/.config/tvheadend:/config"
          "/home/${username}/Lataukset/tvheadend-tallenteet:/recordings"
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
          "--stop-timeout=1"
        ];
      };
    };
  };

  # 3. Automaattinen Btrfs-alitaltion luonti, oikeudet ja No-COW (+C)
  # 'v' luo Btrfs-alitaltion automaattisesti (jää pois snapshot-varmuuskopioista).
  # 'h' asettaa chattr +C -lipun estämään tallenteiden ja tietokannan sirpaloitumisen.
  systemd.tmpfiles.rules = [
    "d /home/${username}/.config/tvheadend 0775 ${username} users - -"
    "h /home/${username}/.config/tvheadend - - - - +C"
    "v /home/${username}/Lataukset/tvheadend-tallenteet 0775 ${username} users - -"
    "h /home/${username}/Lataukset/tvheadend-tallenteet - - - - +C"
  ];

 # 4. Luotettava laitesidonta (udev + systemd)
  services.udev.extraRules = ''
    SUBSYSTEM=="dvb", KERNEL=="*frontend*", MODE="0666", TAG+="systemd", ENV{SYSTEMD_WANTS}+="podman-tvheadend.service"
  '';

  systemd.services.podman-tvheadend = {
    restartIfChanged = false;
    bindsTo = [ "dev-dvb-adapter0-frontend0.device" ];
    after = [ "network-online.target" "dev-dvb-adapter0-frontend0.device" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      SuccessExitStatus = [ 137 143 ];
    };
  };

  # 5. Palomuurin avaukset
  networking.firewall = {
    allowedTCPPorts = [ 9981 9982 ];
    allowedUDPPorts = [ 9982 ];
  };

  # 6. Live TV -pikakuvake työpöytävalikkoon
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "livetv";
      desktopName = "Live TV";
      genericName = "Televisio";
      comment = "Katso TV-lähetyksiä Tvheadendistä MPV-soittimella";
      # exec = "mpv http://localhost:9981/playlist/channels";
      exec = "mpv --ytdl=no --no-resume-playback --osd-playing-msg='\${media-title}' http://localhost:9981/
      # Jos olet määritellyt käyttäjätunnuksen ja salasanan Tvheadendin web-käyttöliittymään:
      # exec = "mpv http://kayttaja:salasana@localhost:9981/playlist/channels";
      icon = "mpv";
      terminal = false;
      categories = [ "AudioVideo" "Video" "Player" "TV" ];
      mimeTypes = [ "x-scheme-handler/pvr" ];
    })
  ];

  # 7. NIXOS-YHTEENSOPIVA AUTOMAATTIPÄIVITYS + LOKITUS (Maanantaisin klo 16:00)
  # Tarkista päivityshistoria: journalctl -u tvheadend-update.service
  # Testaa käsin heti: sudo systemctl start tvheadend-update.service && journalctl -u tvheadend-update.service -n 15
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
      Persistent = true;
    };
  };
}
