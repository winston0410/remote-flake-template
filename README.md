# Flake template for Nginx reverse proxy

Scaffolding an Nginx reverse proxy with Nix.

## Build custom ISO image

```sh
# nixos is the hostname here. Choose the right one according the flake
nix build .#nixosConfigurations.nixos.config.system.build.isoImage
```
