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
    appendWindowsPath = false;
  };

  # Network configuration
  wsl.wslConf.network = {
    generateHosts = true;
    generateResolvConf = true;
  };

  # Windows binary aliases (since appendWindowsPath is false)
  environment.shellAliases = {
    explorer = "/mnt/c/Windows/explorer.exe";
    clip = "/mnt/c/Windows/System32/clip.exe";
    powershell = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe";
    open = "/mnt/c/Windows/System32/cmd.exe /c start";
  };

  # WSL utilities for opening files/URLs in Windows
  environment.systemPackages = with pkgs; [
    wslu
  ];
}
