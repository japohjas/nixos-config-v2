# Btrfs & btrbk – Varmuuskopiointi- ja palautusohje (NixOS)

Tämä ohje kattaa järjestelmääsi määritetyn **btrbk**-varmuuskopioinnin päivittäisen käytön, uuden USB-levyn käyttöönoton, varmuuskopioiden tilan tarkistamisen sekä tiedostojen tai koko kotihakemiston (`@home`) palauttamisen.

---

## 1. Järjestelmän rakenne ja säilytysajat

Järjestelmässä on käytössä kaksi erillistä `btrbk`-instanssia:

| Instanssi | Ajastus | Kohde | Säilytyskäytäntö |
| :--- | :--- | :--- | :--- |
| **`paikalliset-snapshotit`** | Automaattinen (päivittäin) | `/btr_pool/@snapshots` | Vähintään 2 pv, yhteensä 7 päivää ja 12 viikkoa |
| **`usb-varmuuskopio`** | Manuaalinen (`usb-backup`) | `/mnt/backup-usb/btrbk/<koneen-nimi>` | Paikallisesti 2 pv, USB-levyllä 14 pv, 8 vk ja 12 kk |

* **Automaattinen liitos (`automount`):** USB-levy liittyy automaattisesti polkuun `/mnt/backup-usb`, kun hakemistoon viitataan.

---

## 2. Uuden USB-levyn alustaminen ja UUID:n hakeminen

Jos otat käyttöön uuden tyhjän USB-levyn, se on alustettava **Btrfs**-tiedostojärjestelmälle, jotta `btrbk`:n inkrementaalinen `send/receive`-siirto toimii.

> **Varoitus:** Seuraavat toimenpiteet tyhjentävät valitun levyn kokonaan. Tarkista laitetunnus (`sdX`) huolellisesti!

1. **Selvitä USB-levyn laitetunnus:**
   Kytke levy koneeseen ja listaa lohkolaitteet:
   ```bash
   lsblk -o NAME,SIZE,MODEL,TRAN
   ```
   *(Tunnista USB-levy koon ja `usb`-väylätyypin perusteella, esim. `sdb` tai `sdc`.)*

2. **Luo levylle GPT-osiointitaulu ja yksi osio:**
   Korvaa `/dev/sdX` oikealla laitetunnuksella (älä lisää osionumeroa vielä tässä vaiheessa):
   ```bash
   nix-shell -p parted
   sudo parted -s /dev/sdX mklabel gpt
   sudo parted -s /dev/sdX mkpart primary btrfs 0% 100%
   exit
   ```

3. **Alusta uusi osio Btrfs-tiedostojärjestelmälle:**
   Nimeä levy samalla selkeästi (esim. `BACKUP-USB`):
   ```bash
   sudo mkfs.btrfs -f -L BACKUP-USB /dev/sdX1
   ```

4. **Hae osion UUID-tunniste:**
   ```bash
   lsblk -no UUID /dev/sdX1
   ```
   *(Tai näe kaikki tiedot kerralla komennolla `sudo blkid /dev/sdX1`.)*

5. **Päivitä UUID NixOS-konfiguraatioon:**
   * Kopioi saatu UUID-merkkijono (esim. `a1b2c3d4-e5f6-7890-abcd-ef1234567890`).
   * Aseta se koneesi `diskuuid`-muuttujan arvoksi NixOS-konfiguraatiossa.
   * Aja `sudo nixos-rebuild switch`.
   * Ensimmäisellä ajokerralla `usb-backup`-komento luo levylle automaattisesti oikean kansiorakenteen (`/mnt/backup-usb/btrbk/<koneen-nimi>`) ja asettaa sille `btrbk`-käyttäjän oikeudet.

---

## 3. Varmuuskopiointi USB-levylle

### Suositeltu tapa: `usb-backup`-komento
1. Kytke USB-varmuuskopiolevy tietokoneeseen.
2. Avaa pääte ja aja komento:
   ```bash
   usb-backup
   ```
3. Odota, kunnes näet ilmoituksen `✅ Varmuuskopiointi valmis!`, voit irroittaa USB-varmuuskopiolevyn.
   USB-varmuuskopiolevy on irrotettu valmiiksi komenolla:
   ```bash
   sudo umount /mnt/backup-usb
   ```

### Manuaalinen tarkistus ja hallinta
* **Listaa olemassa olevat paikalliset snapshotit:**
  ```bash
  sudo btrbk -c /etc/btrbk/paikalliset-snapshotit.conf list backups
  ```
* **Listaa USB-levyllä olevat varmuuskopiot** (kytke levy ensin kiinni):
  ```bash
  ls /mnt/backup-usb >/dev/null
  sudo btrbk -c /etc/btrbk/usb-varmuuskopio.conf list backups
  ```
* **Tarkista palvelun lokit, jos jokin menee pieleen:**
  ```bash
  journalctl -u btrbk-usb-varmuuskopio.service -n 50 --no-pager
  ```

---

## 4. Palautusohjeet

> **Huomio:** Snapshotit ovat oletuksena kirjoitussuojattuja (`read-only`), joten et voi vahingossa muokata tai tuhota varmuuskopioita niitä selatessasi.

### Vaihtoehto A: Yksittäisten tiedostojen tai kansioiden palautus (Paikallinen snapshot)

1. Listaa paikalliset snapshotit aikaleiman mukaan:
   ```bash
   sudo ls -la /btr_pool/@snapshots
   ```
   *(Nimet ovat muodossa `@home.20261116T201500+0200`)*

2. Kopioi haluamasi tiedosto tai kansio takaisin kotihakemistoosi:
   ```bash
   cp -a /btr_pool/@snapshots/@home.<AIKALEIMA>/polku/tiedostoon ~/polku/tiedostoon
   ```
   *(Valitsin `-a` säilyttää tiedostojen alkuperäiset oikeudet ja aikaleimat.)*

---

### Vaihtoehto B: Yksittäisten tiedostojen palautus USB-levyltä

1. Kytke USB-levy kiinni ja herätä liitos listaamalla kansio (korvaa `<koneen-nimi>` koneesi nimellä, esim. `toshiba-l300`):
   ```bash
   sudo ls -la /mnt/backup-usb/btrbk/<koneen-nimi>
   ```
2. Kopioi haluamasi tiedostot takaisin kotihakemistoosi:
   ```bash
   cp -a /mnt/backup-usb/btrbk/<koneen-nimi>/@home.<AIKALEIMA>/polku/tiedostoon ~/polku/tiedostoon
   ```

---

### Vaihtoehto C: Koko kotihakemiston (`@home`) palautus katastrofitilanteessa

Jos koko `@home`-aliosio on korruptoitunut tai haluat palauttaa sen kokonaisuudessaan tiettyyn ajanhetkeen:

#### 1. Palautus paikallisesta snapshotista
1. Kirjaudu ulos graafisesta istunnosta ja siirry tekstikonsoliin (`Ctrl + Alt + F2`) tai käynnistä kone NixOS Live-USB-tikulta ja liitä Btrfs-juuri:
   ```bash
   sudo mount -o subvolid=5 /dev/sdXY /btr_pool
   ```
2. Siirrä nykyinen rikkinäinen `@home` sivuun turvaan:
   ```bash
   sudo mv /btr_pool/@home /btr_pool/@home_viallinen
   ```
3. Luo uusi **kirjoitettava** (ei `-r`-lippua!) snapshot valitsemastasi varmuuskopiosta `@home`-nimelle:
   ```bash
   sudo btrfs subvolume snapshot /btr_pool/@snapshots/@home.<AIKALEIMA> /btr_pool/@home
   ```
4. Käynnistä tietokone uudelleen:
   ```bash
   sudo reboot
   ```
5. Kun olet varmistanut, että kaikki toimii, voit poistaa vanhan talteen otetun aliosion tilan vapauttamiseksi:
   ```bash
   sudo btrfs subvolume delete /btr_pool/@home_viallinen
   ```

#### 2. Palautus USB-varmuuskopiolevyltä (esim. levyrikon jälkeen)
1. Kun uusi levy on alustettu Btrfs-muotoon ja liitetty polkuun `/btr_pool`, kytke USB-varmuuskopiolevy kiinni (`/mnt/backup-usb`).
2. Lähetä varmuuskopio USB-levyltä takaisin paikalliselle levylle `btrfs send | receive` -putkella:
   ```bash
   sudo btrfs send /mnt/backup-usb/btrbk/<koneen-nimi>/@home.<AIKALEIMA> | sudo btrfs receive /btr_pool/@snapshots/
   ```
3. Luo saapuneesta kirjoitussuojatusta snapshotista varsinainen kirjoitettava `@home`-aliosio:
   ```bash
   sudo btrfs subvolume snapshot /btr_pool/@snapshots/@home.<AIKALEIMA> /btr_pool/@home
   ```
4. Käynnistä järjestelmä uudelleen (`sudo reboot`).
