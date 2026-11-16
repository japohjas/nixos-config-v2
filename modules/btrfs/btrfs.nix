{ config, pkgs, username, ... }:

{
  # Automaattiset kansiorakenteet, nocow-asetukset ja hiekkalaatikon oikeudet
  # Tvheadend määritykset ovat jo valmiiksi tvheadend.nix tiedostossa
  systemd.tmpfiles.rules = [
    # "v /home/${username}/.config/tvheadend 0775 ${username} users - -"

    # Tvheadend-tallenteet (Alavolyymi + NOCOW-varmistus)
    # "v /home/${username}/Lataukset/tvheadend-tallenteet 0775 ${username} users - -"
    # "h /home/${username}/Lataukset/tvheadend-tallenteet - - - - +C"

    # DigiKam-tietokanta (Alavolyymi + NOCOW-varmistus) - tänne digikam tietokanta
    # Digikam piilotiedostot näkyviin hiiren oikealla ja valitaan "Näytä piilotetut tiedostot"
    "v /home/${username}/.local/share/digikam 0775 ${username} users - -"
    "h /home/${username}/.local/share/digikam - - - - +C"

    # Video Downloader (Alavolyymi + NOCOW-varmistus + Flatpak-oikeus)
    # 1. Luodaan btrfs-alavolyymi automaattisesti, jos sitä ei vielä ole
    "v /home/${username}/Lataukset/VideoDownloader 0775 ${username} users - -"

    # 2. Asetetaan +C (nocow) -attribuutti
    "h /home/${username}/Lataukset/VideoDownloader - - - - +C"

    # 3. Annetaan Video Downloader Flatpakille oikeus KÄYTTÄÄ TÄSMÄLLEEN kyseistä kansiota
    "f /var/lib/flatpak/overrides/com.github.unrud.VideoDownloader 0644 root root - [Context]\nfilesystems=/home/${username}/Lataukset/VideoDownloader;"
  ];

    # --- BTRFS AUTOMAATTINEN YLLÄPITO ---
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    # Koska juuri (/) on osion pääjuuri, tämän tarkistaminen
    # käy läpi koko fyysisen levyn ja kaikki sen alilevyt (kuten home ja nix).
    fileSystems = [ "/" ];
  };
  
  services.fstrim.enable = true;
}
