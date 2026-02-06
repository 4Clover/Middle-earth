{
  description = "Middle-earth NixOS-WSL Configuration";

  inputs = {
    # Core nixpkgs - using unstable for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # NixOS-WSL for Windows Subsystem for Linux support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix for secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Common modules shared by all hosts
      commonModules = [
        # NixOS-WSL base module
        nixos-wsl.nixosModules.default

        # sops-nix for secrets
        sops-nix.nixosModules.sops

        # Home Manager as NixOS module
        home-manager.nixosModules.home-manager
        {
          # CRITICAL: Use global pkgs to prevent duplicate nixpkgs evaluation
          home-manager.useGlobalPkgs = true;
          # Install packages to /etc/profiles instead of ~/.nix-profile
          home-manager.useUserPackages = true;
          # Pass inputs to home-manager modules
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];

      # Helper function to create NixOS configurations
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = commonModules ++ [
          ./hosts/${hostName}
        ];
      };
    in
    {
      # NixOS configurations for each host
      nixosConfigurations = {
        # Laptop configuration (LOTR: Legolas - agile, swift)
        legolas = mkHost "legolas";

        # Desktop configuration (LOTR: Aragorn - powerful, kingly)
        aragorn = mkHost "aragorn";
      };

      # Formatter for nix files
      formatter.${system} = pkgs.nixpkgs-fmt;

      # Eval tests to verify configurations build
      checks.${system} = {
        # Test that legolas configuration evaluates
        legolas-eval = self.nixosConfigurations.legolas.config.system.build.toplevel;

        # Test that aragorn configuration evaluates  
        aragorn-eval = self.nixosConfigurations.aragorn.config.system.build.toplevel;
      };
    };
}
