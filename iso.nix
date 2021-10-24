({ pkgs, lib, minimal, format ? "iso", nixos-generators, ... }:
  pkgs.runCommand "minimal-iso" { } ''
    ${nixos-generators}/bin/nixos-generate -f ${format} -c ${minimal} > "$out";
  '')
