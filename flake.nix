{
  description = "NixOS server flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
    hardware = {
      flake = false;
      url = "path:/etc/nixos/hardware-configuration.nix";
    };
  };

  outputs = { self, nixpkgs, hardware, home-manager, ... }:
    let
      system = "x86_64-linux";
      defaultModule = import ./minimal.nix;
    in {
      nixosModule = defaultModule;
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModule
          (import hardware)
          #NOTE Load home-manager options, so that the default HM modules on my local system can be removed
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hugosum = { };
          }
        ];
      };
    };
}
