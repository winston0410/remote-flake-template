({ pkgs, ... }: {
  # Use grub bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

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

  users.users = {
    admin = {
      name = "admin";
      isNormalUser = true;
      home = "/home/admin";
      extraGroups = [ "wheel" ];
      hashedPassword =
        "$6$pHSJA2UTMz$Z5IS7T6E67bshhmPfcAQRRKgbEuOelR23SiB5Os0YqUqX.oDl5P/nhnKbSAYmiU1mHn01tJ90HD11dYQpg1iN0";
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  #NOTE Essential packages
  environment.systemPackages = with pkgs; [ neovim bottom ripgrep ];

  #NOTE Essentail to set EDITOR variable
  environment.variables = {
    "EDITOR" = "nvim";
    "VISUAL" = "nvim";
  };

  environment.shellAliases = {
    "vi" = "nvim";
    "vim" = "nvim";
  };

  #NOTE Remove all default optional packges to reduce a minimal OS
  environment.defaultPackages = [ ];

  services.nginx = {
    enable = true;
    #NOTE So that the configuration file can be found in /etc/nginx/nginx.conf for debug
    enableReload = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    #TODO Define virtual host here
  };

  #NOTE Use podman as the backend of oci-containers
  virtualisation.oci-containers.backend = "podman";
  #TODO Define containers here

  #TODO Define hostName here
  networking.firewall = {
    allowPing = false;
    # Port will be opened by service automatically.
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/London";

  services.openssh = { enable = true; };

  security.acme = { acceptTerms = true; };

  system.stateVersion = "21.11";
  system.autoUpgrade.enable = false;
})
