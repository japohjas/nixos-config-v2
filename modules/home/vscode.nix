{ config, pkgs, ... }: {
  
  programs.vscode = {
    enable = true;

    profiles.default = {
      # Asennetaan laajennukset Nixpkgs-varastosta
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };
  };  
}
