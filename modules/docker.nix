{ config, pkgs, ... }:

{
  # Enable Docker daemon with GPU support
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # NVIDIA container toolkit for GPU support
  # Provides CDI (Container Device Interface) for GPU access in containers
  hardware.nvidia-container-toolkit.enable = true;
}
