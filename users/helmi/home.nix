{ config, pkgs, ... }: {
   
  imports = [
    # ./modules/home/chrome.nix
    # ../../modules/home/chromium.nix
    # ../../modules/home/firefox.nix
    # ../../modules/home/gimp.nix
    # ../../modules/home/git.nix
    # ../../modules/home/mpv-fast.nix
    # ../../modules/home/vivaldi.nix
    # ../../modules/home/vscode.nix
    # ../../modules/home/yt-dlp.nix
  ];
  
  home.packages = with pkgs; [
    
    # Apuohjelmat ja järjestelmä
    # gnome-disk-utility      # udisks graafinen käyttöliittymä
    gnome-calculator        # Laskin
    # cosmic-ext-calculator   # Laskin
    # papers                  # GNOME:n dokumenttikatselin (PDF)
    htop                    # Järjestelmämonitori terminaalissa
    fastfetch               # Järjestelmätietojen haku

    # Cosmic Desktop -kokeilut (unstable)
    # cosmic-viewer           # Yksinkertainen kuvakatselin
    # darktable
    digikam

    # Multimedia ja DVB-T (Digi-TV)
    w_scan2                 # Kanavahaku (esim. w_scan2 -ft -c FI > ~/.config/mpv/channels.conf.ter)
    # ffmpeg-full             # Kattavat video- ja audio-konversiotyökalut
    
    # Tietoturva
    keepassxc               # Salasanahallinta

    # Kommentoidut vaihtoehdot (helppo ottaa käyttöön poistamalla #)
    # catfish               # Tiedostohaku
    # evince                # Vanhempi PDF-katselin
    # eog                   # GNOME kuvakatselin
    # cosmic-ext-calculator
    # thunderbird
  ];
  
  # Bash-asetukset ja aliakset
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # Oman kotihakemiston bin-kansioiden lisääminen PATH-muuttujaan
    # bashrcExtra = ''
    #   export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    # '';
    shellAliases = {
      # Järjestelmän siivous vanhoista sukupolvista ja turhista paketeista
      nix-clean = "sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system && nix-env --delete-generations old && sudo nix-store --gc && sudo nix-store --optimize";    
      # Git-pikakomento
      # g = "git";
    };

    bashrcExtra = ''
      # Viikoittainen päivitysfunktio
      nix-update() {
        cd ~/nixos-config-v2 && \
        nix flake update && \
        git add flake.lock && \
        sudo nixos-rebuild switch --flake .#toshiba-l300 && \
        git commit -m "Viikkopaivitys $(date +%Y-%m-%d)" && \
        flatpak update -y && \
        flatpak uninstall --unused && \
        echo "Päivitys suoritettu"
      }
    '';
  };

  # Asennusajankohta / yhteensopivuusversio,
  # kiinnittää NixOS:n home-managerin asetukset tiettyyn versioon.
  # home.stateVersion = "26.05"; # määritetty flake.nix-tiedostossa
}
