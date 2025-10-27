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
  };

  xdg.configFile = {
    "zed/settings.json" = {
      source = ./zed/settings.json;
    };

    # This manages ~/.config/fish/
    "fish/config.fish" = {
      source = ./fish/config.fish;
    };
  };

  programs.ssh = {
    enable = true;
    authorizedKeys.keys =
      let
        # Path to your public keys, relative to the flake root.
        authorizedKeysDir = ./ssh/authorized_keys;

        # Read all .pub files in that directory and build a list of their contents.
        keyFiles = builtins.filter (file: builtins.match ".*\\.pub" file != null)
          (builtins.attrNames (builtins.readDir authorizedKeysDir));

        # Return a list of the contents of each key file
        keys = builtins.map (keyFile: builtins.readFile (authorizedKeysDir + "/${keyFile}")) keyFiles;
      in
        keys;
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
