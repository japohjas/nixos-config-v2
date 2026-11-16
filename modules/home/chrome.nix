{ config, pkgs, ... }: {
  
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;
    
    # Google Chromen oma moduuli hyväksyy suoraan Nix-listan (List of Strings)
    commandLineArgs = [
      # 1. Natiivi Wayland-tila COSMIC-työpöydälle (turvattu myös globaalilla NIXOS_OZONE_WL muuttujalla)
      # "--ozone-platform-hint=auto" # environment.sessionVariables.NIXOS_OZONE_WL = "1"
      
      # 2. Intel Iris Plus 655 laitteistokiihdytys & suorituskyky
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--use-gl=egl"
      
      # KORJATTU: Ominaisuuksien välissä ei saa olla välilyöntejä pilkun jälkeen (tiukka Chromium-syntaksi!)
      "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer,VaapiVideoDecoder,CanvasOopRasterization"
    ];
  };
}
