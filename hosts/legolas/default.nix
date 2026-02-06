# Host configuration for legolas (laptop)
{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/wsl.nix
  ];

  # WSL Configuration
  wsl.enable = true;
  wsl.defaultUser = "clovr";

  # Networking
  networking.hostName = "legolas";

  # System version
  system.stateVersion = "25.05";

  # sops-nix configuration
  sops.defaultSopsFile = ../../secrets/example.yaml;
  sops.age.keyFile = "/home/clovr/.config/sops/age/keys.txt";

  # Home Manager configuration for user
  home-manager.users.clovr = {
    imports = [ ../../home/common ];
  };
}
