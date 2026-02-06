# Host configuration for aragorn (desktop)
{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/wsl.nix
  ];

  # WSL Configuration
  wsl.enable = true;
  wsl.defaultUser = "clovr";
  wsl.useWindowsDriver = true;  # GPU passthrough for AI workloads

  # Networking
  networking.hostName = "aragorn";

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
