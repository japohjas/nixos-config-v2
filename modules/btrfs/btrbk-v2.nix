{ config, lib, pkgs, hostname, username, diskuuid ? "", ... }:

let
  usbBackupScript = pkgs.writeShellScriptBin "usb-backup" ''
    set -e
    echo "Tarkistetaan USB-varmuuskopiolevyä (/mnt/backup-usb)..."

    # Kysytään sudo-oikeudet heti alussa, jotta prosessi ei jää odottamaan kesken kaiken
    sudo -v

    # Herätetään systemd.automount ja tarkistetaan että levy on oikeasti liitetty
    if ! ls /mnt/backup-usb >/dev/null 2>&1 || ! ${pkgs.util-linux}/bin/mountpoint -q /mnt/backup-usb; then
      echo "VIRHE: USB-varmuuskopiolevyä ei löydy tai sitä ei voitu liittää!"
      echo "Varmista, että levy (UUID: ${diskuuid}) on kytketty koneeseen."
      exit 1
    fi

    echo "Levy havaittu! Käynnistetään varmuuskopiointi (älä irrota levyä)..."

    # Näytetään VAIN btrbk-ohjelman omat tulosteet (ei sudo/pam-lokeja)
    journalctl _SYSTEMD_UNIT=btrbk-usb-varmuuskopio.service SYSLOG_IDENTIFIER=btrbk -o cat -n 0 -f &
    LOG_PID=$!
    trap "kill $LOG_PID 2>/dev/null || true" EXIT

    if sudo systemctl start btrbk-usb-varmuuskopio.service; then
      sleep 0.5
      echo ""
      echo "Kirjoitetaan puskuri ja irrotetaan levy turvallisesti..."
      sync
      sudo umount /mnt/backup-usb
      echo ""
      echo "✅ Varmuuskopiointi valmis ja levy irrotettu turvallisesti."
    else
      sleep 0.5
      echo ""
      echo "❌ Varmuuskopiointi epäonnistui! Tarkista loki: journalctl -u btrbk-usb-varmuuskopio.service -n 30"
      exit 1
    fi
  '';
in
{
  config = lib.mkMerge [
    # 1. Paikalliset automaattiset snapshotit (käytössä kaikilla koneilla)
    {
      services.btrbk.instances."paikalliset-snapshotit" = {
        onCalendar = "daily";
        settings = {
          timestamp_format = "long";
          snapshot_preserve_min = "2d";
          snapshot_preserve = "7d 12w";
          volume."/btr_pool" = {
            subvolume = "@home";
            snapshot_dir = "@snapshots";
          };
        };
      };

      systemd.services."btrbk-paikalliset-snapshotit".serviceConfig = {
        AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
      };

      environment.systemPackages = [ pkgs.btrbk ];
    }

    # 2. USB-levy ja manuaalinen varmuuskopiointi (vain jos diskuuid on annettu)
    (lib.mkIf (diskuuid != "") {
      fileSystems."/mnt/backup-usb" = {
        device = "/dev/disk/by-uuid/${diskuuid}";
        fsType = "btrfs";
        options = [
          "noauto"
          "nofail"
          "compress=zstd:1"
          "noatime"
          "discard=async"
          "x-mount.mkdir"
          "x-systemd.automount"
          # Poistettu x-systemd.idle-timeout=60, jotta se ei katkaise pitkiä siirtoja!
          "x-gvfs-show"
        ];
      };

      services.btrbk.instances."usb-varmuuskopio" = {
        onCalendar = null;
        settings = {
          timestamp_format = "long";
          snapshot_create = "ondemand";
          snapshot_preserve_min = "latest";
          snapshot_preserve = "2d";
          target_preserve_min = "latest";
          target_preserve = "14d 8w 12m";
          volume."/btr_pool" = {
            subvolume = "@home";
            snapshot_dir = "@snapshots";
            target = "/mnt/backup-usb/btrbk/${hostname}";
          };
        };
      };

      systemd.services."btrbk-usb-varmuuskopio" = {
        unitConfig.RequiresMountsFor = "/mnt/backup-usb";
        serviceConfig = {
          ReadWritePaths = [ "/mnt/backup-usb" ];
          PermissionsStartOnly = true;
          AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
        };
        preStart = ''
          mkdir -p /mnt/backup-usb/btrbk/${hostname}
          chown btrbk:btrbk /mnt/backup-usb/btrbk/${hostname}
        '';
      };

      environment.systemPackages = [ usbBackupScript ];
    })
  ];
}
