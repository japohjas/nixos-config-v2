{ config, pkgs, ... }: {
  
  # Hauppauge PCTV - ajuri, toimii ainakin flake-ympäristössä
  # 1. Salli ei-vapaat laiteohjelmistot (vaaditaan useimmille TV-korteille)
  # aktivoitu tiedostossa intel-graphics.nix
  # hardware.enableRedistributableFirmware = true;

  # 2. Haetaan puuttuva Si2168-laiteohjelmisto vakaalla tarkistussummalla
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
      name = "si2168-b40-firmware";
      
      src = pkgs.fetchurl {
        url = "https://github.com/OpenELEC/dvb-firmware/raw/master/firmware/dvb-demod-si2168-b40-01.fw";
        # sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" # sha256 tarkistussumma saadaan tällä
        sha256 = "sha256-hQdTZjDXWjFtBxnWuVwEuQw2uqW0V61FfJusra/O8TQ=";
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/lib/firmware
        cp $src $out/lib/firmware/dvb-demod-si2168-b40-01.fw
      '';
    })
  ];
}


