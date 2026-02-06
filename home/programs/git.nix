{ config, pkgs, ... }:

{
  # Git configuration with 1Password SSH signing
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "4Clover";
        email = "dlmannion@ucdavis.edu";
        # 1Password SSH signing key
        # SETUP INSTRUCTIONS:
        #   1. Install 1Password 8 on Windows
        #   2. Settings → Developer → Enable "SSH Agent"
        #   3. Settings → Developer → Enable "WSL Integration"
        #   4. Create or import SSH key in 1Password
        #   5. Copy public key and replace PLACEHOLDER below
        #   6. Verify op-ssh-sign.exe path (may differ by 1Password version)
        signingkey = "key::ssh-ed25519 PLACEHOLDER";
      };

      init.defaultBranch = "prod";

      core = {
        autocrlf = "input";        # Convert CRLF→LF on commit, leave LF alone
        fileMode = true;
        symlinks = true;
        longpaths = true;
        fsmonitor = true;          # Performance boost for large repos
        untrackedCache = true;     # Cache untracked file status
      };

      pull.rebase = true;           # Rebase on pull instead of merge
      push.autoSetupRemote = true;  # Auto set upstream on first push
      fetch.prune = true;           # Prune deleted remote branches on fetch
      diff.algorithm = "histogram"; # Better diff algorithm
      merge.conflictStyle = "diff3"; # Show base in conflict markers
      rerere.enabled = true;        # Remember conflict resolutions

      # 1Password SSH signing
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.program = "/mnt/c/Users/clovr/AppData/Local/1Password/app/8/op-ssh-sign.exe";

      alias = {
        s = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        amend = "commit --amend --no-edit";
      };
    };

    ignores = [
      ".direnv"
      ".envrc"
      "result"
      "result-*"
    ];
  };

  # SSH configuration for 1Password agent
  # 1Password WSL integration creates Unix socket at ~/.1password/agent.sock
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      extraOptions = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
