({ pkgs, ... }: {
  # Use grub bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  
  nixpkgs.config = { allowUnfree = true; };

  #NOTE Expect breakage
  environment.noXlibs = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    binaryCaches = [ "https://cache.nixos.org" ];
    trustedBinaryCaches = [ "http://cache.nixos.org" "http://hydra.nixos.org" ];
    optimise = {
      automatic = true;
      dates = [ "12:00" ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Essential
  environment.systemPackages = with pkgs; [
    neovim
    bottom
    ripgrep
  ];

  services.nginx = {
    enable = true;
    #NOTE So that the configuration file can be found in /etc/nginx/nginx.conf for debug
    enableReload = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    # virtualHosts."bot" = {
    # addSSL = true;
    # enableACME = true;
    # locations."/" = { proxyPass = "http://localhost:3000"; };
    # };
  };

  #NOTE Use podman as the backend of oci-containers
  virtualisation.oci-containers.backend = "podman";

  networking.firewall.allowPing = false;

  networking.firewall.allowedTCPPorts = [ 80 443 22 ];

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    banner = "";
  };

  security.acme = {
    acceptTerms = true;
    # email = "hugosum.dev@protonmail.com";
  };

  system.autoUpgrade.enable = false;
})
