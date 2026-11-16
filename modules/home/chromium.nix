{ config, pkgs, ... }: {

  # Intel Core i5-8259U -suoritin ja integroitu Intel Iris Plus Graphics 655 -näytönohjain
  # Intel Coffee Lake ei tue lainkaan AV1-videomuodon laitteistotason rautakiihdytystä (HW decode)
  # Sallitaan suljetut binäärit (VAADITAAN Widevinea varten) Järjestelmätasolla
  
  programs.chromium = {
    enable = true;
    
    # Otetaan käyttöön suoraan paketti, jossa mukana Widevine DRM
    package = pkgs.chromium.override {
      enableWideVine = true;
    };

    # Laajennukset (Home Manager sallii sekä merkkijonot että { id = "..."; } -muodon)
    # Merkkijonolista muunnetaan automaattisesti oikeaksi alimoduuliksi taustalla
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "omkfmpieigblcllmkgbflkikinpkodlk" # enhanced-h264ify (Konfiguroi estämään VAIN AV1, salli VP9/H.264)
    ];

    # Jätetään argumentteihin puhdas suorituskyky, rautakiihdytys ja Wayland-tuki
    commandLineArgs = [ 
      # Laitteistokiihdytys ja nollakopiointi NUC8i5 Intel GPU:lle
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      
      # Aktivoidaan Linux-rautakiihdytys muille koodekeille (VP9, H.264) ja WebRTC PipeWire -tuki
      "--enable-features=VaapiVideoDecoder,WebRTCPipeWireCapturer,CanvasOopRasterization"
      
      # TURVALLISUUS: Pakotetaan salasanojen salaus GNOME Keyringiin
      "--password-store=gnome-libsecret"
    ];
  };
}
