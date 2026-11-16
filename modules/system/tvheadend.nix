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

  # Varmistetaan vain, että verkko on valmis ennen kuin kontti yrittää sitoutua portteihin
  systemd.services.podman-tvheadend = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  # Podman tarvitsee konttien perushallinnan aktivoitua
  virtualisation.containers.enable = true; 
  
  # Kun dns_enabled = true on käytössä, voit luoda Podmanilla omia verkkoja, 
  # joissa kontit löytävät toisensa suoraan nimen perusteella.
  # ne voivat (esim kodi kontti) yhdistää Tvheadendiin pelkällä osoitteella 
  # http://tvheadend:9981
  # virtualisation.containers.settings = {
  #   network.default_network_settings.dns_enabled = true;
  # };

  # Määritellään Tvheadend-kontti kotihakemistopoluilla
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      tvheadend = {
        image = "lscr.io/linuxserver/tvheadend:latest";
        autoStart = true;  
        
        ports = [
          "9981:9981" # Web-käyttöliittymä
          "9982:9982" # HTSP-striimaus
        ];

        volumes = [
          "/home/${username}/.config/tvheadend:/config"
          "/home/${username}/Videot/tvheadend-tallenteet:/recordings"
        ];

        # $ id
        environment = {
          PUID = "1000";        
          PGID = "100";         
          TZ = "Europe/Helsinki";
        };

        # Oikeudet TV-viritinlaitteeseen (/dev/dvb)
        extraOptions = [
          "--device=/dev/dvb:/dev/dvb:rw" # Läpivienti luku- ja kirjoitusoikeuksin
          "--ipc=host"                     # Parantaa laiteyhteyksiä host-koneeseen
          "--security-opt=label=disable"   # Estää SELinux/NixOS-oikeusblokit laitteeseen
          # "--user=0:0" poistettu, jotta linuxserver-kuvan PUID/PGID logiikka toimii oikein
          # Podmanin virallinen label, jonka systemd-päivityspalvelu lukee
          "--label=io.containers.autoupdate=registry" 
        ];
      };
    };
  };

  # Automaattinen kansioiden luonti ja oikeuksien korjaus
  # Tämä poistaa tarpeen ajaa mkdir/chown/chmod-komentoja käsin ${username}'n kotihakemistossa.
  systemd.tmpfiles.rules = [
    "d /home/${username}/.config/tvheadend 0775 ${username} users - -"
    "d /home/${username}/Videot/tvheadend-tallenteet 0775 ${username} users - -"
  ];

  # ---------------------------------------------------------------------
  # KORJAUS: VARMA UDEV-SÄÄNTÖ LATEEN KYTKENNÄLLE BOOTIN JÄLKEEN
  # ---------------------------------------------------------------------
  # Aina kun tikku lisätään (add) – oli kone juuri käynnistetty tai ei –
  # udev ajaa suoraan 'restart'-komennon. Jos kontti ei ollut päällä, se käynnistyy.
  # Jos kontti oli jo vikatilassa päällä, se käynnistetään uudelleen uuden laitteen kanssa.
  # ---------------------------------------------------------------------
  services.udev.extraRules = ''
    SUBSYSTEM=="dvb", ACTION=="add", MODE="0666", RUN+="${pkgs.systemd}/bin/systemctl restart podman-tvheadend.service"
    SUBSYSTEM=="dvb", ACTION=="remove", RUN+="${pkgs.systemd}/bin/systemctl stop podman-tvheadend.service"
  '';
  # ---------------------------------------------------------------------



  # Avataan palomuuri
  networking.firewall = {
    allowedTCPPorts = [ 9981 9982 ];
    allowedUDPPorts = [ 9982 ]; # HTSP hyötyy joskus myös UDP-portista vakauden vuoksi
  };

  # Luodaan Live TV -pikakuvake globaalisti NixOS-tyyliin makeDesktopItem-työkalulla
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "livetv";
      desktopName = "Live TV";
      genericName = "Televisio";
      comment = "Katso TV-lähetyksiä Tvheadendistä MPV-soittimella";
      exec = "mpv http://localhost:9981/playlist/channels";
      icon = "mpv";
      terminal = false;
      categories = [ "AudioVideo" "Video" "Player" "TV" ];
      mimeTypes = [ "x-scheme-handler/pvr" ];
    })
  ];

  # 1. PALVELU, JOKA SUORITTAA AUTOMAATTISEN PÄIVITYKSEN KERRAN VIIKOSSA
  # sudo systemctl start podman-auto-update.service   # Käynnistää päivityksen heti
  # sudo systemctl status podman-auto-update.service  # Näyttää palvelun tilan ja lokit
  # sudo journalctl -u podman-auto-update.service -f  # Seurata päivityksen etenemistä
  # sudo podman auto-update  # Suorittaa automaattisen ilman systemd:tä päivityksen kontille, jos se on käynnissä
  # sudo podman ps           # Listaa käynnissä olevat kontit
  systemd.services."podman-auto-update" = {
    description = "Podman konttien automaattinen päivitys";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    # Määritetään tarvittavat työkalut palvelun käyttöön
    path = with pkgs; [ podman coreutils ]; 
    
    # Suoritettava komentoriviskripti
    script = ''
      ${pkgs.podman}/bin/podman auto-update
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  # 2. AKTIVOIDAAN PODMANIN OMA AUTOMAATTIPÄIVITYS SYSTEMD-AJASTIMELLA
  systemd.timers."podman-auto-update" = {
    description = "Ajastin Podman konttien automaattiselle päivitykselle";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # KORJAUS: Tyhjennetään oletusaikataulut ja asetetaan uusi tarkka maanantai klo 16:00
      OnCalendar = [ "" "Mon *-*-* 16:00:00" ]; 
      Persistent = false;
    };
  };
}
