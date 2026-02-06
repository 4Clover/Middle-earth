# Middle-earth: The Ultimate NixOS-WSL Fresh Install Guide

Welcome to the definitive setup guide for **Middle-earth**, a declaratively managed, high-performance NixOS-WSL environment. This guide is designed to take you from a fresh Windows installation to a fully operational, GPU-accelerated NixOS development environment.

Whether you are setting up the mighty **Aragorn** or the agile **Legolas**, follow these steps precisely to ensure a stable and secure system.

---

## Section 1: Overview & Naming Convention

### The Philosophy
Middle-earth is built on the principle of **Infrastructure as Code**. Every package, configuration file, and system setting is defined in this Nix Flake. This ensures that your development environment is reproducible, version-controlled, and easily portable between machines.

### Host Naming Convention
We follow a *Lord of the Rings* theme for our infrastructure:

1.  **Aragorn (The Desktop)**:
    *   **Role**: Primary workstation for heavy workloads, AI/ML development, and high-end gaming.
    *   **Hardware**: AMD Ryzen 9 9950X3D (16 Cores/32 Threads), 32GB DDR5 RAM, NVIDIA RTX 4090.
    *   **Characteristics**: Maximum performance, high power consumption, stationary.

2.  **Legolas (The Laptop)**:
    *   **Role**: Mobile development machine for work on the go.
    *   **Hardware**: Intel Core i9-11900H (8 Cores/16 Threads), 16GB DDR4 RAM (Upgradable to 48GB), NVIDIA RTX 3060 Laptop.
    *   **Characteristics**: Balanced performance, energy efficient, portable.

### Universal Defaults
*   **User**: `clovr` is the primary user across all machines.
*   **Shell**: Zsh with Starship prompt and FZF integration.
*   **Editor**: NeoVim/VS Code (configured via home-manager).
*   **Secrets**: Managed via `sops-nix` using `age` encryption.

---

## Section 2: Windows Prerequisites

Before touching Linux, your Windows host must be properly prepared.

### 2.1 Windows Version
Ensure you are running **Windows 11 (22H2 or later)**. While WSL2 works on Windows 10, many of the advanced features used in this configuration (like mirrored networking and auto memory reclaim) require Windows 11.

### 2.2 Enable WSL2
Open PowerShell as Administrator and run:
```powershell
wsl --install
```
If WSL is already installed, ensure it is up to date:
```powershell
wsl --update
```

### 2.3 Windows Terminal
Install **Windows Terminal** from the Microsoft Store. It is the only terminal that correctly handles the complex rendering required by our Starship prompt and modern CLI tools.

### 2.4 NVIDIA Drivers (CRITICAL)
If your machine has an NVIDIA GPU, install the latest **Game Ready Driver** or **Studio Driver** from [nvidia.com](https://www.nvidia.com/Download/index.aspx).

> [!CAUTION]
> **WSL GPU ARCHITECTURE RULE**: You must **ONLY** install the NVIDIA driver on the Windows host. **NEVER** attempt to install an NVIDIA driver inside the NixOS-WSL environment. WSL shares the host's driver via a specialized interface. Installing a Linux driver inside WSL will break GPU acceleration.

### 2.5 1Password Setup
We use 1Password for secure SSH key management and Git commit signing.
1.  Install **1Password 8 for Windows**.
2.  Open 1Password Settings → **Developer**.
3.  Enable **Use the SSH agent**.
4.  Enable **WSL Integration**.
5.  Ensure you have an SSH key (Ed25519 recommended) in your 1Password vault.

---

## Section 3: Apply .wslconfig

The `.wslconfig` file controls the resource allocation and experimental features of the WSL2 VM. Our repository provides optimized templates for each host.

### 3.1 What .wslconfig Does
Our configuration enables several "Experimental" (but stable) features:
*   `networkingMode=mirrored`: Allows WSL to share the host's IP and supports localhost forwarding.
*   `autoMemoryReclaim=gradual`: Automatically releases Linux RAM back to Windows.
*   `sparseVhd=true`: Prevents the WSL disk from bloating by reclaiming unused space.

### 3.2 Installation
We provide an automated installer in the `windows/` directory.
1.  Open PowerShell.
2.  Navigate to your cloned repository (on the Windows side for now, or just download the script).
3.  Run the installer:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    .\windows\install.ps1
    ```
    The script will detect your hostname (Aragorn or Legolas) and copy the correct template to `%USERPROFILE%\.wslconfig`.

### 3.3 Apply Changes
For the settings to take effect, you **must** restart WSL:
```powershell
wsl --shutdown
```

### 3.4 Verification
After starting WSL, verify the memory allocation:
```bash
free -h
```
It should match the values defined in your host's `.wslconfig` (e.g., 16GB for Aragorn, 8GB for Legolas).

---

## Section 4: Install NixOS-WSL

We use the community-maintained NixOS-WSL distribution as our base.

### 4.1 Download
1.  Go to the [NixOS-WSL Releases](https://github.com/nix-community/NixOS-WSL/releases) page.
2.  Download the latest `nixos.wsl` file.

### 4.2 Import
Open PowerShell and run the import command. Replace `<path-to-nixos.wsl>` with your actual download path.
```powershell
wsl --import NixOS $env:USERPROFILE\NixOS <path-to-nixos.wsl> --version 2
```

### 4.3 First Boot as Root
The initial distribution has a default user `nixos`. However, our flake creates the user `clovr` and sets up complex permissions. You **MUST** perform the first boot as root to apply the configuration.

```powershell
wsl -d NixOS -u root
```

---

## Section 5: Generate Age Key

**THIS IS THE MOST CRITICAL STEP.** Our configuration uses `sops-nix` to encrypt secrets (like API keys and private configs). These secrets are encrypted using the `age` format. If you do not have a valid age key, `nixos-rebuild` will fail.

### 5.1 Enter Nix Shell
Since `age` isn't installed yet, use a temporary Nix shell:
```bash
nix-shell -p age
```

### 5.2 Create Key Directory
```bash
mkdir -p ~/.config/sops/age
```

### 5.3 Generate Key
```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

### 5.4 Extract Public Key
Run this command and copy the output (it starts with `age1...`):
```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

### 5.5 Update .sops.yaml
You must register your new public key in the `.sops.yaml` file at the root of the repository so that the system knows which key can decrypt the secrets.

---

## Section 6: Clone & Configure Repository

### 6.1 The "Golden Rule" of Performance
> [!IMPORTANT]
> **NEVER** clone your development repositories into `/mnt/c/` (the Windows filesystem). The performance penalty for cross-filesystem operations in WSL is 10x-100x. Always work inside the Linux filesystem (e.g., `~/Nix/Middle-earth`).

### 6.2 Cloning
```bash
mkdir -p ~/Nix
git clone https://github.com/4Clover/Middle-earth.git ~/Nix/Middle-earth
cd ~/Nix/Middle-earth
```

### 6.3 Register Your Key
Open `.sops.yaml` and add your public key from Section 5.4.
```yaml
keys:
  - &my_host age1...your_key_here...
```
Add it to the `creation_rules` section as well.

### 6.4 Stage Changes
Nix Flakes only "see" files that are tracked by Git.
```bash
git add .
```

---

## Section 7: First Rebuild

Now it's time to transform the generic NixOS-WSL image into your customized Middle-earth environment.

### 7.1 Run Rebuild
Replace `<hostname>` with either `aragorn` or `legolas`.
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### 7.2 What Happens Now?
Nix will download all required packages, configure the system, create the `clovr` user, set up Docker, and install your home-manager configuration. This may take several minutes depending on your internet speed.

### 7.3 Switch User
Once the rebuild completes, exit the root session:
```bash
exit
```
Then restart WSL to login as the new `clovr` user:
```powershell
wsl -d NixOS
```
You should now see the Starship prompt and be logged in as `clovr`!

---

## Section 8: Post-Install Setup

### 8.1 Verify GPU Acceleration
Run the following to ensure your RTX GPU is visible to NixOS:
```bash
nvidia-smi
```
If you see the GPU status table, acceleration is working.

### 8.2 Finalize Git Signing
1.  Open your 1Password vault.
2.  Copy the **Public Key** of your SSH key.
3.  Edit `home/programs/git.nix` in the repository.
4.  Replace `PLACEHOLDER` in `user.signingkey` with your actual public key.
5.  Run `rebuild` (the alias we created) to apply the change.

### 8.3 Test Docker
Verify that Docker is running and you have permissions:
```bash
docker run hello-world
```
To test GPU support in Docker:
```bash
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

### 8.4 Verify Zsh Plugins
*   **FZF**: Press `Ctrl+R` to search history or `Ctrl+T` to find files.
*   **Autosuggestions**: Start typing a command you've used before; press `Right Arrow` to complete it.
*   **Syntax Highlighting**: Valid commands appear green, invalid ones red.

---

## Section 9: Troubleshooting Common Issues

### 9.1 Age Key Missing
**Symptoms**: `nixos-rebuild` fails with "Could not find age key" or "Permission denied" when reading secrets.
**Fix**: Ensure your key is at `~/.config/sops/age/keys.txt` and its public part is in `.sops.yaml`. If you moved the file, set `export SOPS_AGE_KEY_FILE=/path/to/keys.txt`.

### 9.2 NVIDIA Driver Not Found
**Symptoms**: `nvidia-smi` returns "command not found" or "failed to initialize".
**Fix**: Ensure you installed the **Windows** driver. In your Nix configuration (`hosts/<hostname>/default.nix`), ensure `wsl.useWindowsDriver = true;` is set.

### 9.3 Docker Permission Denied
**Symptoms**: `docker ps` returns "permission denied".
**Fix**: Your user must be in the `docker` group. This is handled by our configuration, but may require a full WSL restart (`wsl --shutdown`) to apply group membership.

### 9.4 WSL2 Resource Bloat
**Symptoms**: Windows is slow, and Vmmem is consuming 90% of RAM.
**Fix**: Check that `.wslconfig` is properly applied. Run `wsl --shutdown` and then `free -h` in WSL to verify the limit is respected.

### 9.5 Git Signing Fails
**Symptoms**: `git commit` fails with "error: gpg failed to sign the data".
**Fix**: Verify that 1Password is running on Windows and "SSH Agent" is enabled. Ensure `op-ssh-sign.exe` path in `home/programs/git.nix` is correct for your 1Password version.

---

## Section 10: Maintenance & Updates

Maintaining a NixOS system is different from traditional Linux.

### 10.1 Updating the System
To update all packages to their latest versions defined in the channels:
```bash
nfu      # Alias for 'nix flake update'
rebuild  # Alias for 'sudo nixos-rebuild switch --flake .#<hostname>'
```

### 10.2 Garbage Collection
Nix keeps every version of every package you've ever installed so you can roll back. Over time, this consumes disk space.
*   **Automatic**: Our configuration runs GC weekly and keeps 30 days of history.
*   **Manual**: To free up space immediately:
    ```bash
    nix-collect-garbage -d
    ```

### 10.3 Health Checks
Before committing changes to your flake, run the check suite:
```bash
nfc      # Alias for 'nix flake check'
```

### 10.4 Updating WSL Kernel
Microsoft occasionally releases new WSL kernels. Keep yours updated via PowerShell:
```powershell
wsl --update
```

---

*“All we have to decide is what to do with the time that is given us.”* – Gandalf

You are now ready to build great things in Middle-earth. Happy hacking!
