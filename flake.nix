{
  description = "NixOS server flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # flake-utils = {
      # url = "github:numtide/flake-utils";
      # inputs = { nixpkgs.follows = "nixpkgs"; };
    # };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      defaultModule = import ./minimal.nix;
    in {
      nixosModule = defaultModule;
      nixosModules = {
        default = defaultModule;
        secret = agenix.nixosModules.age;
      };
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModule
          #NOTE Load home-manager options, so that the default HM modules on my local system can be removed
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = { };
          }
        ];
      };
    };
}
