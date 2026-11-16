{ config, lib, pkgs, diskuuid, ... }:

lib.mkIf (diskuuid != "") {
  # Sisäinen Samsung SSD 1 T (ext4)
  # Kiinteästi kotelon sisällä (SATA-väylässä)
  # UUID: b98a7ceb-2b22-42f5-8e0d-078810b7fee9
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/${diskuuid}";
    fsType = "ext4";
    options = [
      "defaults"                    # Liitetään normaalisti käynnistyksen yhteydessä
      "nofail"                      # Estää vikatilan (emergency mode), jos levy hajoaa tai irrotetaan
      "noatime"                     # Vähentää turhaa kirjoitusta ja pidentää SSD:n ikää
      "x-mount.mkdir"               # Luo /mnt/backup-kansion automaattisesti
      "x-systemd.device-timeout=5"  # Ei hidasta käynnistystä turhaan vikatilanteessa
      "x-gvfs-show"                 # Näyttää levyn graafisen tiedostonhallinnan sivupalkissa
    ];
  };
}
