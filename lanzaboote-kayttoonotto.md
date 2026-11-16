# Lanzaboote ja Secure Boot – Käyttöönotto-ohje (NixOS)

Tämä ohje kuvaa vaiheet ja tarkan järjestyksen Secure Bootin käyttöönottoon NixOS-koneella **Lanzaboote**-moduulin ja `sbctl`-työkalun avulla.

---

## Esivaatimukset

Ennen aloittamista varmista seuraavat asiat:
* Kone käyttää **UEFI**-käynnistystä (ei vanhaa Legacy/CSM-tilaa).
* Käynnistyslataajana toimii aluksi tavallinen `systemd-boot`.
* BIOS/UEFI-asetuksissa **Secure Boot on pois päältä** (tai *Setup Mode* -tilassa).

---

## Käyttöönoton vaiheet järjestyksessä

### 1. Luo allekirjoitusavaimet
Luo konekohtaiset Secure Boot -avaimet ennen kuin otat Lanzabooten käyttöön NixOS-konfiguraatiossa:

```bash
sudo nix-shell -p sbctl --run "sbctl create-keys"
```
> Avaimet tallentuvat oletuksena hakemistoon `/var/lib/sbctl`.

---

### 2. Ota Lanzaboote käyttöön Flakessa ja rakenna järjestelmä
Aseta `flake.nix`-tiedostossa kyseisen koneen profiiliin `secureBoot = true` (tai määritä `boot.lanzaboote.enable = true` ja `boot.loader.systemd-boot.enable = lib.mkForce false`).

Rakenna ja ota muutokset käyttöön:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
*(Korvaa `<hostname>` koneesi nimellä, esim. `nuc8i5`.)*

---

### 3. Tarkista käynnistystiedostojen allekirjoitukset
Varmista ennen uudelleenkäynnistystä, että Lanzaboote on allekirjoittanut EFI-käynnistystiedostot oikein:

```bash
sudo sbctl verify
```
> Kaikkien `/boot/EFI/...`-polun tiedostojen kohdalla tulisi näkyä vihreä kuittaus (`✓ ... is signed`).

---

### 4. Aseta BIOS/UEFI *Setup Mode* -tilaan
1. Käynnistä kone uudelleen ja siirry **BIOS/UEFI-asetuksiin**.
2. Etsi **Secure Boot** -valikko.
3. Kytke **Secure Boot päälle** (`Enabled`).
4. Tyhjennä olemassa olevat tehdasavaimet valinnalla **Clear Secure Boot Keys** / **Delete All Keys** / **Reset to Setup Mode** (nimi vaihtelee emolevyn valmistajan mukaan).
5. Tallenna asetukset ja käynnistä kone takaisin NixOS:ään.

---

### 5. Rekisteröi omat avaimet UEFI-firmwarelle
Kun kone on käynnistynyt *Setup Mode* -tilassa, rekisteröi luodut avaimet UEFI-muistiin:

```bash
sudo sbctl enroll-keys --microsoft
```
> **Huomio `--microsoft`-valinnasta:** Valitsin on vahvasti suositeltava, jotta emolevyn ja näytönohjaimen laiteohjelmistot (OpROM) sekä mahdollinen Windows-dualboot toimivat ongelmitta.

---

### 6. Käynnistä uudelleen ja varmista lopputulos
Käynnistä tietokone vielä kerran uudelleen ja tarkista Secure Bootin tila terminaalissa:

```bash
bootctl status
```

Onnistuneen käyttöönoton jälkeen tulosteessa näkyy:
```text
Secure Boot: enabled (user)
```

Voit tarkistaa tilan myös komennolla:
```bash
sudo sbctl status
```
Tulosteessa tulisi lukea:
* `Setup Mode: ✓ Disabled`
* `Secure Boot: ✓ Enabled`
