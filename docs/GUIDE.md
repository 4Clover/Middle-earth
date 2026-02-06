# Middle-earth: NixOS-WSL Configuration Guide

Welcome to Middle-earth, a declaratively managed NixOS-WSL environment. This guide will walk you through setting up your machine from scratch, switching from a standard Ubuntu WSL distribution to NixOS, and managing your configuration with Flakes and home-manager.

## LOTR Naming Convention

All machines in this infrastructure are named after characters from *The Lord of the Rings*.

*   **`legolas`**: The Laptop. Agile, mobile, and precise. Used for development on the go.
*   **`aragorn`**: The Desktop. Powerful, the "King of the Desktop." Used for heavy workloads and gaming.
*   **`clovr`**: The universal username used across all machines.

## Prerequisites

Before you begin, ensure you have the following installed on your Windows host:

1.  **WSL2**: Ensure you are running the latest version of WSL2.
    *   Command (PowerShell): `wsl --update`
2.  **Windows Terminal**: Strongly recommended for a better terminal experience.
3.  **Basic Nix Knowledge**: You should be comfortable with the command line and basic Linux concepts.

## Bootstrap Process

### Step 1: Install NixOS-WSL

We use the community-maintained NixOS-WSL distribution.

1.  Download the latest `nixos.wsl` file from the [NixOS-WSL Releases](https://github.com/nix-community/NixOS-WSL/releases/latest).
2.  **Import the distribution**:
    *   Open PowerShell and run:
        ```powershell
        wsl --import NixOS $env:USERPROFILE\NixOS nixos.wsl --version 2
        ```
    *   Alternatively, if you downloaded the `.wsl` installer (WSL >= 2.4.4), just double-click it.
3.  **Launch NixOS**:
    ```powershell
    wsl -d NixOS
    ```

### Step 2: Generate Age Key (CRITICAL)

We use `sops-nix` for secret management. **You MUST generate your age key before your first system rebuild**, or the build will fail because it cannot decrypt secrets.

1.  Install `age`:
    ```bash
    nix-shell -p age
    ```
2.  Generate the key:
    ```bash
    mkdir -p ~/.config/sops/age
    age-keygen -o ~/.config/sops/age/keys.txt
    ```
3.  **Extract your public key**:
    ```bash
    age-keygen -y ~/.config/sops/age/keys.txt
    ```
    *Take note of this key (it starts with `age1...`). You will need to add it to the `.sops.yaml` file in the repository root.*

### Step 3: Configure Repository

1.  Clone this repository into your home directory (ensure it stays on the WSL filesystem, e.g., `~/Nix/Middle-earth`).
2.  Add your new public key to `.sops.yaml`:
    ```yaml
    keys:
      - &my_new_host <YOUR_PUBLIC_KEY>
    creation_rules:
      - path_regex: secrets/.*\.yaml$
        key_groups:
          - age:
            - *my_new_host
    ```
3.  If you are adding a new host, you may need to update existing secrets:
    ```bash
    nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"
    ```

### Step 4: First Rebuild

Run the initial rebuild to apply the configuration. Replace `hostname` with `legolas` or `aragorn`.

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Configuration Management

### Day-to-Day Workflow

When you make changes to your configuration:

1.  Navigate to the repository root.
2.  Apply changes:
    ```bash
    sudo nixos-rebuild switch --flake .
    ```
    *Note: The flake will automatically detect your hostname.*

### Adding a New Host

1.  Create a new directory in `hosts/` for your new host.
2.  Create a `default.nix` in that directory and define the system configuration.
3.  Add the host to `flake.nix` under `nixosConfigurations`.
4.  Generate an age key for the host (as shown in the Bootstrap section).
5.  Add the host's public key to `.sops.yaml`.

## Troubleshooting

### Filesystem Performance
**NEVER** work on projects located in `/mnt/c/`. The performance overhead of the 9P protocol between WSL and Windows is significant. Always keep your repository and development files within the WSL ext4 filesystem (e.g., `~/projects`).

### GPU Passthrough (aragorn)
If you are setting up `aragorn` and need GPU support (NVIDIA/CUDA):
*   Ensure `wsl.useWindowsDriver = true` is set in your NixOS configuration.
*   The Windows NVIDIA driver must be installed on the host.

### sops-nix: "Age key not found"
If you see an error about missing keys:
*   Verify the key exists at `~/.config/sops/age/keys.txt`.
*   Check that the environment variable `SOPS_AGE_KEY_FILE` is correctly set if you are using a non-standard path.

### Evaluation Errors
If `nixos-rebuild` fails during evaluation:
*   Ensure all files are added to git. Flakes only "see" files that are tracked by the git repository.
*   Run `git add .` and try again.

## References

*   [NixOS-WSL Documentation](https://nix-community.github.io/NixOS-WSL/)
*   [sops-nix Repository](https://github.com/Mic92/sops-nix)
*   [Official NixOS Manual](https://nixos.org/manual/nixos/stable/)
*   [Home Manager Manual](https://nix-community.github.io/home-manager/)
