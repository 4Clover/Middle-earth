{ config, pkgs, ... }:

{
  imports = [
    ../programs/opencode.nix
    ../programs/git.nix
    ../programs/zsh.nix
  ];

  home.stateVersion = "25.05";

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
}
