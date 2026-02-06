# Windows WSL Configuration

This directory contains per-host `.wslconfig` templates for WSL2 optimization.

## What is .wslconfig?

`.wslconfig` is a Windows-side configuration file that controls WSL2 VM settings:
- Memory allocation (how much RAM WSL can use)
- CPU cores (how many processors WSL can access)
- Swap size (virtual memory for WSL)
- Network mode (mirrored networking for better Windows/WSL integration)
- And more (see [Microsoft docs](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#wslconfig))

## Host Configurations

- **aragorn.wslconfig**: Desktop (32GB DDR5, 16-core Ryzen 9950X3D, RTX 4090)
  - 16GB memory (50% of total)
  - 12 processors (75% of cores)
  - 8GB swap

- **legolas.wslconfig**: Laptop (16GB DDR4, 8-core i9-11900H, RTX 3060 Laptop)
  - 8GB memory (50% of total)
  - 6 processors (75% of cores)
  - 4GB swap
  - **Note**: After RAM upgrade to 48GB, edit the file and adjust memory to 24GB, swap to 12GB

## Installation

### Option A: Automatic (Recommended)

Run the installer script from PowerShell (in this directory):

```powershell
.\install.ps1
```

The script will:
1. Auto-detect your hostname (aragorn or legolas)
2. Copy the correct .wslconfig to `%USERPROFILE%\.wslconfig`
3. Warn if an existing .wslconfig will be overwritten
4. Remind you to restart WSL

### Option B: Manual

Copy the appropriate file manually:

```powershell
# For aragorn (desktop)
Copy-Item windows\aragorn.wslconfig $env:USERPROFILE\.wslconfig

# For legolas (laptop)
Copy-Item windows\legolas.wslconfig $env:USERPROFILE\.wslconfig
```

## Applying Changes

After copying the file, you MUST restart WSL for changes to take effect:

```powershell
wsl --shutdown
wsl -d NixOS
```

## Verification

Check that WSL is using the correct settings:

```bash
# Check memory allocation
free -h

# Check CPU cores
nproc

# Check swap
swapon --show
```

## When to Re-run

Re-run the installer if you:
- Change hardware (upgrade RAM, etc.)
- Want to adjust memory/CPU allocation
- Reinstall Windows
- Switch between hosts (laptop ↔ desktop)
