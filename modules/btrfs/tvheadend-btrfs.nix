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

  # ---------------------------------------------------------------------
  # 1. USB-VIRITTIMEN TUKI (FIRMWARE)
  # ---------------------------------------------------------------------
  hardware.enableRedistributableFirmware = true;

  virtualisation.containers.enable = true;

  # Odotetaan, että verkko on ylhäällä ennen kontin käynnistystä
  systemd.services.podman-tvheadend = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  # ---------------------------------------------------------------------
  # 2. BTRFS-AJURIN OPTIMOINTI PODMANILLE
  # ---------------------------------------------------------------------
  # Määritetään vain ajuri ilman globaalia graphroot-polkua,
  # jotta rootless-podman ei mene rikki eikä järjestelmä anna varoitusta.
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "btrfs";
    };
  };

  # ---------------------------------------------------------------------
  # 3. TVHEADEND-KONTTI (ROOT PODMAN)
  # ---------------------------------------------------------------------
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
          "/home/${username}/Lataukset/tvheadend-tallenteet:/recordings"
        ];
        environment = {
          PUID = "1000";
          PGID = "100"; # NixOS oletus 'users' GID
          TZ = "Europe/Helsinki";
        };
        # Oikeudet TV-viritinlaitteeseen (/dev/dvb) ja ryhmäoikeuksien ohitus (bypassing SELinux/Access)
        extraOptions = [
          "--device=/dev/dvb:/dev/dvb:rw"
          "--ipc=host"
          "--security-opt=label=disable"
          "--label=io.containers.autoupdate=registry"
        ];
      };
    };
  };

  # ---------------------------------------------------------------------
  # 4. KANSIOIDEN LUONTI BTRFS-ALIVOLYMEINÄ (SUBVOLUMES) JA NOCOW (+C)
  # ---------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    # Asetukset (.config) luodaan tavallisena hakemistona
    "d /home/${username}/.config/tvheadend 0775 ${username} users - -"
    
    # Luodaan tallenteet aitona Btrfs-subvolumeena (v = subvolume)
    "v /home/${username}/Lataukset/tvheadend-tallenteet 0775 ${username} users - -"
    
    # Pakotetaan NoCoW (+C) uuteen tallennussubvolumeen pirstoutumisen estämiseksi
    "h /home/${username}/Lataukset/tvheadend-tallenteet - - - - +C"
  ];

  # ---------------------------------------------------------------------
  # 5. UDEV-SÄÄNTÖ USB-VIRITTIMEN TUNNISTUKSELLE KÄYNNISTYKSESSÄ
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
  # 6. PALOMUURIASETUKSET
  # ---------------------------------------------------------------------
  networking.firewall = {
    allowedTCPPorts = [ 9981 9982 ];
    allowedUDPPorts = [ 9982 ];
  };

  # ---------------------------------------------------------------------
  # 7. LIVE TV -PIKEA-KUVAKE JÄRJESTELMÄÄN
  # ---------------------------------------------------------------------
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "livetv";
      desktopName = "Live TV";
      genericName = "Televisio";
      comment = "Katso TV-lähetyksiä Tvheadendistä MPV-soittimella";
      exec = "${pkgs.mpv}/bin/mpv http://localhost:9981/playlist/channels";
      icon = "mpv";
      terminal = false;
      categories = [ "AudioVideo" "Video" "Player" "TV" ];
      mimeTypes = [ "x-scheme-handler/pvr" ];
    })
    pkgs.mpv
  ];

  # ---------------------------------------------------------------------
  # 8. KONTTIEN AUTOMAATTINEN PÄIVITYS (MAANANTAISIN KLO 16:00)
  # ---------------------------------------------------------------------
  systemd.services."podman-auto-update" = {
    description = "Podman konttien automaattinen päivitys";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ podman coreutils ];
    script = ''
      ${pkgs.podman}/bin/podman auto-update
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  systemd.timers."podman-auto-update" = {
    description = "Ajastin Podman-konttien automaattiselle päivitykselle";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = [ "" "Mon *-*-* 16:00:00" ];
      Persistent = false;
    };
  };
}
