# Secrets Management with sops-nix

This directory contains encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix).

## Bootstrap Process

### 1. Install Prerequisites

Ensure `sops` and `age` are available:

```bash
nix-shell -p sops age
```

### 2. Generate Age Key

Create your age encryption key:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

**IMPORTANT**: Back up this key file securely. Without it, you cannot decrypt your secrets.

### 3. Get Your Public Key

Extract your age public key:

```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

This will output something like:
```
age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 4. Update .sops.yaml

Edit `.sops.yaml` in the repository root and replace `<AGE_PUBLIC_KEY>` with your actual public key:

```yaml
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: >-
      age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 5. Encrypt Secrets

Edit and encrypt the example secrets file:

```bash
sops secrets/example.yaml
```

This will:
- Open your default editor
- Allow you to replace placeholder values with real secrets
- Automatically encrypt the file when you save and exit

### 6. Apply Configuration

Rebuild your NixOS system:

```bash
sudo nixos-rebuild switch --flake .#legolas
```

## Usage in NixOS Configuration

Secrets are configured in host configurations with:

```nix
{
  sops.defaultSopsFile = ../../secrets/example.yaml;
  sops.age.keyFile = "/home/clovr/.config/sops/age/keys.txt";
  
  sops.secrets.opencode-api-key = {
    owner = "clovr";
  };
}
```

Access secrets in your configuration via:
- File path: `/run/secrets/opencode-api-key`
- Nix attribute: `config.sops.secrets.opencode-api-key.path`

## Usage in Home Manager

For user-level secrets, configure in `home/common/default.nix`:

```nix
{ config, ... }:
{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
}
```

## Adding New Secrets

1. Edit the encrypted file:
   ```bash
   sops secrets/example.yaml
   ```

2. Add your new secret in YAML format:
   ```yaml
   myservice:
     api_key: "actual-secret-value"
   ```

3. Save and exit (file is automatically encrypted)

4. Reference in your NixOS config:
   ```nix
   sops.secrets.myservice-api-key = {
     owner = "clovr";
   };
   ```

## Security Notes

- **NEVER** commit unencrypted secrets to git
- **ALWAYS** back up your age key (`~/.config/sops/age/keys.txt`)
- The age key must exist BEFORE running `nixos-rebuild`
- Encrypted files are safe to commit to version control
- Each host/user needs their own age key added to `.sops.yaml`

## Troubleshooting

### "Failed to get the data key"

Your age key is not in `.sops.yaml` or the file was encrypted with a different key.

Solution: Re-encrypt with your key:
```bash
sops updatekeys secrets/example.yaml
```

### "No such file or directory: /run/secrets/..."

The secret wasn't declared in your NixOS configuration or the system hasn't been rebuilt.

Solution: Add `sops.secrets.<name> = {};` and rebuild.

### "age key not found"

The age key file doesn't exist at the configured path.

Solution: Generate the key (step 2) or update `sops.age.keyFile` path.
