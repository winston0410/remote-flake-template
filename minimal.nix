({ pkgs, ... }: {
  nixpkgs.config = { allowUnfree = true; };

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
    git
    arion
    docker-client
    # For better listing
    lsd
    # For monitoring and debugging
    bottom
    ripgrep
    fd
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

  virtualisation.docker.enable = false;
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.dnsname.enable = true;
  };

  networking.useDHCP = false;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

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
