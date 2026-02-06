{ config, pkgs, ... }:

{
  # Enable systemd in WSL
  wsl.wslConf.boot.systemd = true;

  # Automount configuration
  wsl.wslConf.automount = {
    enabled = true;
    root = "/mnt";
    options = "metadata,uid=1000,gid=100";
  };

  # Interop settings
  wsl.wslConf.interop = {
    enabled = true;
    appendWindowsPath = true;
  };

  # Network configuration
  wsl.wslConf.network = {
    generateHosts = true;
    generateResolvConf = true;
  };
}
