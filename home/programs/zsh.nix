{ config, pkgs, ... }:

{
  # Zsh shell configuration with Pure Nix plugins (no oh-my-zsh framework)
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;

    # Autosuggestions from command history
    autosuggestion.enable = true;

    # Syntax highlighting for commands
    syntaxHighlighting.enable = true;

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;  # Commands starting with space aren't saved
      share = true;         # Share history between sessions
    };

    # Shell aliases for common commands
    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      ".." = "cd ..";
      "..." = "cd ../..";
      rebuild = "sudo nixos-rebuild switch --flake ~/Nix/Middle-earth";
      nfu = "nix flake update";
      nfc = "nix flake check";
    };

    # Additional initialization for key bindings
    initExtra = ''
      # Bind keys for history substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';

    # Pure Nix plugins (no oh-my-zsh framework)
    plugins = [
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];
  };

  # Fuzzy finder integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
  };

  # Starship prompt for Zsh
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      directory.truncation_length = 3;
      git_branch.symbol = " ";
      nix_shell.symbol = " ";
    };
  };

  # Shell utilities for enhanced command-line experience
  home.packages = with pkgs; [
    fd          # Better find, used by fzf
    ripgrep     # Better grep
    bat         # Better cat
    eza         # Better ls (modern replacement)
  ];

  # NOTE: Setting Zsh as default shell requires NixOS-level configuration.
  # This is handled in host configs (Task 9) via:
  #   programs.zsh.enable = true;        # NixOS-level
  #   users.users.clovr.shell = pkgs.zsh;
}
