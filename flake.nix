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
    agenix = {
      url = "github:ryantm/agenix";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # nixos-generator = {
      # url = "github:nix-community/nixos-generators";
      # inputs = { nixpkgs.follows = "nixpkgs"; };
    # };
  };

  outputs =
    { self, nixpkgs, hardware, home-manager, agenix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      defaultModule = import ./minimal.nix;
      defaultPackage = pkgs.callPackage ./iso.nix {
        minimal = ./minimal.nix;
        nixos-generator =
          pkgs.nixos-generator.override { nix = pkgs.nixUnstable; };
      };
    in {
      defaultPackage.${system} = defaultPackage;
      packages.${system} = { default = defaultPackage; };
      nixosModule = defaultModule;
      nixosModules = {
        default = defaultModule;
        secret = agenix.nixosModules.age;
      };
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
            home-manager.users = { };
          }
        ];
      };
    };
}
