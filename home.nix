{ config, pkgs, ... }:

{
  # === NO PACKAGE MANAGEMENT ===
  home.packages = [];

  programs.home-manager.enable = true;

  home.file = {
    ".gemini/settings.json" = {
      source = ./gemini/settings.json;
    };
    ".ssh/config" = {
      source = ./ssh/config;
    };
    ".ssh/mrw-droid-github.pub" = {
      source = ./ssh/mrw-droid-github.pub;
    };
    ".ssh/authorized_keys" = {
      source = ./ssh/mrw-droid-github.pub;
    };
  };

  xdg.configFile = {
    "zed/settings.json" = {
      source = ./zed/settings.json;
    };
    "zed/keymap.json" = {
      source = ./zed/keymap.json;
    };

    # This manages ~/.config/fish/
    "fish/config.fish" = {
      source = ./fish/config.fish;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          "IdentitiesOnly" = "yes";
          "SendEnv" = "LANG LC_*";
          "HashKnownHosts" = "yes";
        };
      };
    };
  };

  ### SSH Keys and Config ###

  home.sessionVariables = {
    SOPS_GCP_KMS_IDS = "projects/nix-dotfiles/locations/global/keyRings/sops-keyring/cryptoKeys/sops-key";
  };

  sops = {
    defaultSopsFile = ./secrets.sops.yaml;
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
    secrets."github_ssh_key" = {
      path = "${config.home.homeDirectory}/.ssh/mrw-droid-github";
      mode = "0600";
    };
  };
}
