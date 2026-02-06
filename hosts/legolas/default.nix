# Host configuration for legolas (laptop)
# Stub - will be fully implemented in later tasks
{ config, pkgs, inputs, ... }:

{
  # Required for NixOS-WSL
  wsl.enable = true;
  wsl.defaultUser = "clovr";

  # Required state version
  system.stateVersion = "25.05";
}
