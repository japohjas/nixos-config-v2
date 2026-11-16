{ config, pkgs, ... }: {

  # nuc8i5 coffee-lake
  # CPU: Intel(R) Core(TM) i5-8259U (8) @ 3.80 GHz
  # GPU: Intel Iris Plus Graphics 655 @ 1.05 GHz [Integra] (gen9)

  # Thermald estää Intel-suorittimen ylikuumenemisen ja hallitsee lämpöprofiileja
  services.thermald.enable = true;  
  
  # Pidetään myös muut työpöytä- ja grafiikkaoptimoinnit aktiivisina
  hardware.enableRedistributableFirmware = true; 
  
  hardware.graphics = {
    enable = true;  # Aktivoi automaattisesti Intel ANV Vulkan -ajurit ja loaderin
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      # vpl-gpu-rt # For QSV/VPL API support on Tiger Lake (2020) or newer processors.
      intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
      intel-compute-runtime-legacy1 # OpenCL-tuki, tukee Gen8, Gen9 ja Gen11 -piirejä
    ];
  };
  
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Optionally, set the environment variable
  
}  
