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
  # suppressNvidiaDriverAssertion = true because WSL2 provides drivers via wsl.useWindowsDriver
  hardware.nvidia-container-toolkit = {
    enable = true;
    suppressNvidiaDriverAssertion = true;
  };
}
