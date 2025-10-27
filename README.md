# SSH Key Management Strategy

This document outlines the concrete plan for managing SSH access across the fleet using a modern, passkey-based hybrid approach.

## 1. Philosophy

The goal is a declarative, secure, and convenient SSH setup. We achieve this by combining:
- **Platform Authenticators (TPM/Secure Enclave)**: For seamless, passwordless logins from primary machines.
- **Roaming Authenticators (YubiKey)**: For secure, portable access from any machine.
- **Emergency Passphrase Key**: For "break-glass" disaster recovery scenarios.

All public keys are managed declaratively by Nix/Home-Manager. All private key material is stored encrypted in the repository using SOPS.

## 2. Key Inventory

| Hostname | Key Name | Type | Purpose |
| :--- | :--- | :--- | :--- |
| `scholomance` | `scholomance-se` | `ed25519-sk` | Primary key for the M2 Ultra Mac, using the Secure Enclave. |
| `murderbot` | `murderbot-tpm` | `ed25519-sk` | Primary key for the Linux PC, using the TPM. |
| `culture` | `culture-se` | `ed25519-sk` | Primary key for the personal MacBook Pro, using the Secure Enclave. |
| `microserfs` | `microserfs-se` | `ed25519-sk` | Primary key for the work MacBook Pro, using the Secure Enclave. |
| (Physical Key) | `yubikey-primary` | `ed25519-sk` | Roaming key for portable access. |
| (Emergency) | `emergency-recovery`| `ed25519` | Disaster recovery key, protected by a strong passphrase. |

## 3. Action Plan

Follow these steps to generate the keys and integrate them into the repository.

### Preliminary Step: Create Directories

Run these commands once from the root of this repository:

```bash
mkdir -p ssh/authorized_keys
mkdir -p secrets/ssh
```

---

### Step 1: Generate Platform Keys

#### On `scholomance` (macOS)
```bash
# Generate the key, authenticating with Touch ID / Apple Watch
ssh-keygen -t ed25519-sk -C "mrw@scholomance" -f ~/.ssh/scholomance-se

# Add the public key to this repository
cp ~/.ssh/scholomance-se.pub ssh/authorized_keys/

# Add the private key handle to this repository and encrypt it
cp ~/.ssh/scholomance-se secrets/ssh/
sops --encrypt --in-place secrets/ssh/scholomance-se
```

#### On `murderbot` (Linux)
*Note: You may need to install `libfido2` first (e.g., `sudo apt install libfido2-1`).*
```bash
# Generate the key, authenticating with your login password/biometrics
ssh-keygen -t ed25519-sk -C "mrw@murderbot" -f ~/.ssh/murderbot-tpm

# Add the public key to this repository
cp ~/.ssh/murderbot-tpm.pub ssh/authorized_keys/

# Add the private key handle to this repository and encrypt it
cp ~/.ssh/murderbot-tpm secrets/ssh/
sops --encrypt --in-place secrets/ssh/murderbot-tpm
```

#### On `culture` (macOS)
```bash
# Generate the key, authenticating with Touch ID / Apple Watch
ssh-keygen -t ed25519-sk -C "mrw@culture" -f ~/.ssh/culture-se

# Add the public key to this repository
cp ~/.ssh/culture-se.pub ssh/authorized_keys/

# Add the private key handle to this repository and encrypt it
cp ~/.ssh/culture-se secrets/ssh/
sops --encrypt --in-place secrets/ssh/culture-se
```

#### On `microserfs` (macOS)
```bash
# Generate the key, authenticating with Touch ID / Apple Watch
ssh-keygen -t ed25519-sk -C "mrw@microserfs" -f ~/.ssh/microserfs-se

# Add the public key to this repository
cp ~/.ssh/microserfs-se.pub ssh/authorized_keys/

# Add the private key handle to this repository and encrypt it
cp ~/.ssh/microserfs-se secrets/ssh/
sops --encrypt --in-place secrets/ssh/microserfs-se
```

---

### Step 2: Generate Roaming Key (YubiKey)

Plug in your YubiKey and run this on any machine.

```bash
# Generate the key, tapping the YubiKey to confirm
ssh-keygen -t ed25519-sk -C "mrw@yubikey-primary" -f ~/.ssh/yubikey-primary

# Add the public key to this repository
cp ~/.ssh/yubikey-primary.pub ssh/authorized_keys/

# Add the private key handle to this repository and encrypt it
cp ~/.ssh/yubikey-primary secrets/ssh/
sops --encrypt --in-place secrets/ssh/yubikey-primary
```

---

### Step 3: Generate Emergency Key

Run this on any machine.

```bash
# Generate a standard ed25519 key
ssh-keygen -t ed25519 -C "mrw@emergency-recovery" -f ~/.ssh/emergency-recovery

# When prompted, enter a new, very strong, and unique passphrase.
# Store this passphrase somewhere safe (e.g., a password manager).

# Add the public key to this repository
cp ~/.ssh/emergency-recovery.pub ssh/authorized_keys/

# Add the private key to this repository and encrypt it
cp ~/.ssh/emergency-recovery secrets/ssh/
sops --encrypt --in-place secrets/ssh/emergency-recovery
```

## 4. Home Manager Configuration

Add the following code to your `home.nix` to declaratively manage the `authorized_keys` file on all machines in the fleet.

```nix
{ config, pkgs, ... }:

let
  # Path to your public keys, relative to the flake root.
  # This assumes your home.nix is in the same directory as the `ssh` folder.
  authorizedKeysDir = ./ssh/authorized_keys;

  # Read all .pub files in that directory and build a list of their contents.
  authorizedKeys = builtins.map (keyFile: builtins.readFile (authorizedKeysDir + "/${keyFile}"))
    (builtins.attrNames (builtins.readDir authorizedKeysDir));
in
{
  # ... other home-manager configuration
  programs.ssh = {
    enable = true;
    # This option takes a list of strings, where each string is a public key.
    authorizedKeys.keys = authorizedKeys;
  };
  # ... other home-manager configuration
}
```

## 5. Deployment

After generating the keys and adding the Nix code:
1. Commit all changes to the repository.
2. Run `home-manager switch` on each machine in the fleet.

This will distribute the public keys and ensure every machine authorizes the new set of keys.
