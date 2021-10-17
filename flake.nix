{
  description = "NixOS server flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    hardware = {
      flake = false;
      url = "path:/etc/nixos/hardware-configuration.nix";
    };
  };

  outputs = { self, nixpkgs, hardware, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (import hardware)
          ({ pkgs, ... }: {
            nixpkgs.config = { allowUnfree = true; };

            # Essential
            environment.systemPackages = with pkgs; [ neovim git ];

            services.nginx = {
              enable = true;
              recommendedGzipSettings = true;
              recommendedTlsSettings = true;
              recommendedOptimisation = true;
              recommendedProxySettings = true;
              virtualHosts."bot" = {
                addSSL = true;
                enableACME = true;
              };
            };

            networking.useDHCP = false;
            networking.firewall.allowedTCPPorts = [ 80 443 ];

            security.acme = {
              acceptTerms = true;
              email = "REDACTED";
            };
          })
        ];
      };
    };
}
