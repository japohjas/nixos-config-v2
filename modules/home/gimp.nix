{ config, pkgs, ... }: {
  
  home.packages = [
    (pkgs.gimp-with-plugins.override {
      plugins = with pkgs.gimpPlugins; [
        resynthesizer # Älykäs täyttö ja objektien poisto
        gmic          # Kattava suodatin- ja tehostekirjasto
        # fourier       # Fourier-muunnoskuvasuodattimet
        # gap           # GIMP Animation Package animaatioille
      ];
    })
  ];
}
