{ config, pkgs, ... }: {
  
  programs.git = {
    enable = true;
    settings.user = {
      name = "Jari Pohjasmaki";
      email = "japohjas@gmail.com";
    };
  };  
}
