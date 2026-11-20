
##### VS Code esikatselu .md: shift+ctrl+v

## Hakemistorakenne
### ~/nixos-config-v2/

```text
├── flake.nix
├── flake.lock
├── hosts/                             # LAITEKOHTAISET asetukset
│   └── nuc8i5/
│   │   ├── configuration.nix          # Järjestelmäasetukset
│   │   └── hardware-configuration.nix # Hw-configuration
│   │
│   └── toshiba-l300/
│       ├── configuration.nix          # Järjestelmäasetukset
│       └── hardware-configuration.nix # Hw-configuration (swapfile) + erillinen zram-tmp.nix
│
├── modules/                           # UUDELLEENKÄYTETTÄVÄT moduulit
│   ├── system/
│   │   ├── plasma-desktop.nix         # Plasma työpöytä
│   │   ├── backup-ext4.nix            # ssd kovalevy varmuuskopiointiin    
│   │   ├── cosmic-desktop.nix         # Cosmic työpöytä
|   |   ├── fonts.nix                  # fontteja + emojit
│   │   ├── garbage-collection.nix     # Siivousautomaatio
│   │   ├── intel-nuc8i5.nix           # nuc8i5beh näytönohjainajuri
│   │   ├── pctv-firmware.nix          # Hauppauge PCTV - ajuri
│   │   ├── zram-tmp.nix               # zram + /tmp RAM-muistiin
│   │   └── tvheadend.nix              # podman + tvheadend, ext4
|   |
│   ├── btrfs/
|   |   ├── btrbk-v2.nix               # Varmuuskopiointi, btrfs
|   |   ├── btrbk-ohje-v2.md           # Ohje 
|   |   ├── btrfs.nix                  # Alavolyymit + NOCOW, digikam, Video Downloader (flatpak), btrfs automaattinen ylläpito
|   |   └── tvheadend-btrfs.nix        # btrfs optimoitu podman + tvheadend 
|   |
│   └── home/                         # YHTEISET Home-Manager-moduulit
│      ├── chrome.nix
│      ├── chromium.nix
|      ├── firefox.nix
│      ├── gimp.nix
│      ├── git.nix
|      ├── mpv.fast.nix
|      ├── mpv.nix
|      ├── vivaldi.nix
|      ├── vscode.nix
│      └── yt-dlp.nix
│
└── users/                            # KÄYTTÄJÄKOHTAISET profiilit
    ├── jari/
    │   └── home.nix
    └── helmi/
        └── home.nix
    
```
