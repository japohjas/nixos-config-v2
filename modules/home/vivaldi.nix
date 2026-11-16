{ config, pkgs, ... }: {

  # Hallitaan Vivaldia Chromium-moduulin kautta
  programs.chromium = {
    enable = true;
    
    # Määritetään selaimeksi Vivaldi (Widevine ja koodekit tulevat mukana automaattisesti)
    package = pkgs.vivaldi;

    # Jätetään argumentteihin vain puhdas suorituskyky, rautakiihdytys ja Wayland-tuki
    commandLineArgs = [ 
      # Laitteistokiihdytys ja nollakopiointi NUC8i5 Intel GPU:lle
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      
      # Aktivoidaan Linux-rautakiihdytys (VP9, H.264) ja WebRTC PipeWire -tuki
      # Huom: AV1 poistettu tästä, koska Iris Plus 655 ei tue sitä rautatasolla
      "--enable-features=VaapiVideoDecoder,WebRTCPipeWireCapturer,CanvasOopRasterization"
    ];
  }; 
}
