{ pkgs, ... }: {

  fonts.packages = with pkgs; [
    open-sans                # COSMIC käyttöliittymän oletusfontti
    noto-fonts               # Yleinen tekstiperhe
    noto-fonts-color-emoji   # Korjaa puuttuvat emojit
    nerd-fonts.symbols-only  # Korjaa puuttuvat kehittäjäikonit, waybar
  ];
}