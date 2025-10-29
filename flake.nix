{
  description = "mrw-home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Make it use the same nixpkgs
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }: {
    myHomeModule = import ./home.nix;

    # murderbot (x86 desktop)
    homeConfigurations."murderbot" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { hostname = "murderbot"; };
      modules = [
        self.myHomeModule
        sops-nix.homeManagerModules.sops
        {
          home.username = "mrw";
          home.homeDirectory = "/home/mrw";
          home.stateVersion = "24.05";
        }
      ];
    };

    # scholomance (m2u)
    homeConfigurations."scholomance" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      extraSpecialArgs = { hostname = "scholomance"; };
      modules = [
        self.myHomeModule
        sops-nix.homeManagerModules.sops
        {
          home.username = "mrw";
          home.homeDirectory = "/Users/mrw";
          home.stateVersion = "24.05";
        }
      ];
    };

    # mrw-rl (work laptop)
    # culture (home laptop)
  };
}
