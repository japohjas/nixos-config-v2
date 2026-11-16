
##### VS Code esikatselu .md: shift+ctrl+v

## Hakemistorakenne
### ~/nixos-config-v2/

```text
├── flake.nix                          # Flake, joka sitoo kaiken yhteen
├── flake.lock
├── hosts/                             # LAITEKOHTAISET ASETUKSET
│   └── nuc8i5/
│   │   ├── configuration.nix          # NUC:n omat järjestelmäasetukset
│   │   └── hardware-configuration.nix # NUC:n hardware-configuration.nix
│   │
│   └── toshiba-l300/
│       ├── configuration.nix          # Toshiba-l300 omat järjestelmäasetukset
│       └── hardware-configuration.nix # Toshiban levyn osiointi (swapfile) + erillinen zram-tmp.nix
│
├── modules/                           # UUDELLEENKÄYTETTÄVÄT MODUULIT
│   ├── system/                        # Yhteiset NixOS-järjestelmämoduulit (esim. boot, verkko)
│   │   ├── plasma-desktop.nix         # Plasma työpöytä
│   │   ├── backup-ssd.nix             # ssd kovalevy varmuuskopiointiin, nuc8i5      
│   │   ├── cosmic-desktop.nix         # Cosmic työpöytä
|   |   ├── fonts.nix                  # fontteja + emojit
│   │   ├── garbage-collection.nix     # Siivousautomaatio
│   │   ├── intel-nuc8i5.nix           # nuc8i5beh näytönohjainajuri
│   │   ├── pctv-firmware.nix          # Hauppauge PCTV - ajuri
│   │   ├── zram-tmp.nix               # zram + /tmp RAM-muistiin
│   │   └── tvheadend.nix              # podman + tvheadend, ext4 
│   ├── btrfs/
|   |   ├── btrbk-ai.nix               # Snapshots 
|   |   ├── btrbk.md                   # Ohje 
|   |   ├── btrfs.nix                  # Alavolyymit + NOCOW, digikam, Video Downloader (flatpak), btrfs automaattinen ylläpito
|   |   └── tvheadend-btrfs.nix        # btrfs optimoitu podman + tvheadend 
|   |
│   └── home/                         # Yhteiset Home-Manager-moduulit (sovellukset)
│      ├── git.nix                    # Git-asetukset
│      ├── mpv.nix                    # mpv mediasoitin nuc asetukset
       ├── mpv-fast.nix               # mpv mediasoitin kevyet asetukset
│      ├── yt-dlp.nix                 # yt-dlp lataus asetukset
│      ├── vscode.nix                 # VS Code asetukset  
│      └── shell.nix                  # Zsh/Bash, aliakset, htop
│
└── users/                            # KÄYTTÄJÄKOHTAISET PROFIILIT
    ├── jari/
    │   └── home.nix               # Jarin kaikki Home-Manager-asetukset ja sovellukset
    └── helmi/
        └── home.nix               # Helmin omat Home-Manager-asetukset ja sovellukset    
    
```

## Flake-projektikansiossa

```
cd ~/nixos-config-v2
git init
git add .
nixos flake update
git add flak.lock
git commit -m "initial commit"
sudo nixos-rebuild switch --flake .#nuc8i5
```

## Update
### 1. Päivitä Flaken riippuvuudet (luo tai muuttaa flake.lock-tiedoston)
nix flake update

### 2. Lisää MUUTTUNUT flake.lock (ja varmuuden vuoksi flake.nix) Gitiin
git add flake.nix flake.lock

### 3. Tee commit päivityksestä
git commit -m "Päivitetty flaken riippuvuudet"

### 4. Päivitä järjestelmä
sudo nixos-rebuild switch --flake .

```bash
#!/usr/bin/env bash

### Sijoitetaan tiedostoon: /home/helmi/nixos-config/paivita.sh
### Ajo komennolla: ./paivita.sh

### Asetetaan skripti pysähtymään heti, jos jokin komento epäonnistuu
set -e

echo "🔄 1/4 Päivitetään Flaken riippuvuudet..."
nix flake update

echo "💾 2/4 Lisätään muuttuneet tiedostot Gitiin..."
git add flake.nix flake.lock

echo "📝 3/4 Tehdään Git-commit..."
git commit -m "Päivitetty flaken riippuvuudet ($(date +'%d.%m.%Y'))"

echo "🚀 4/4 Rakennetaan ja otetaan käyttöön uusi NixOS-järjestelmäversio..."
sudo nixos-rebuild switch --flake .#toshiba-l300

echo "✅ Päivitys suoritettu onnistuneesti!"
```