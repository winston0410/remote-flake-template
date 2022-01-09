{ email, sshKeys, ... }:
({ pkgs, lib, ... }: {
  # Use grub bootloader
  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.grub.version = 2;

  nixpkgs.config = { allowUnfree = true; };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes

      #NOTE https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
      min-free = ${builtins.toString (100 * 1024 * 1024)}
    '';
    binaryCaches = [ "https://cache.nixos.org" ];
    trustedBinaryCaches = [ "http://cache.nixos.org" "http://hydra.nixos.org" ];
    #REF https://github.com/serokell/deploy-rs/issues/25
    trustedUsers = [ "@wheel" ];
    allowedUsers = [ "@wheel" ];
    autoOptimiseStore = true;
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

  #TODO Define podman auto-prune

  #NOTE Reduce journald size
  services.journald.extraConfig = ''
    SystemMaxUse=50M
  '';

  users.users = {
    admin = {
      name = "admin";
      isNormalUser = true;
      home = "/home/admin";
      extraGroups = [ "wheel" ];
      hashedPassword =
        "$6$pHSJA2UTMz$Z5IS7T6E67bshhmPfcAQRRKgbEuOelR23SiB5Os0YqUqX.oDl5P/nhnKbSAYmiU1mHn01tJ90HD11dYQpg1iN0";
      openssh.authorizedKeys.keyFiles = sshKeys;
    };

    #NOTE Overwrite the default for root
    root = {
      name = "root";
      uid = 0;
      isSystemUser = true;
      hashedPassword =
        "$6$pHSJA2UTMz$Z5IS7T6E67bshhmPfcAQRRKgbEuOelR23SiB5Os0YqUqX.oDl5P/nhnKbSAYmiU1mHn01tJ90HD11dYQpg1iN0";
      openssh.authorizedKeys.keyFiles = sshKeys;
    };
  };

  security.sudo = {
    enable = lib.mkDefault false;
    wheelNeedsPassword = false;
  };

  #NOTE Essential packages
  environment.systemPackages = with pkgs; [ neovim bottom ];

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
  environment.defaultPackages = lib.mkForce [ ];

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
    allowedTCPPorts = [ 80 443 ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/London";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    allowSFTP = lib.mkDefault false;
    #NOTE https://christine.website/blog/paranoid-nixos-2021-07-18
    #NOTE https://cisofy.com/lynis/controls/SSH-7408/
    extraConfig = ''
      AllowTcpForwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
      MaxSessions 2
      MaxAuthTries 3
      ClientAliveCountMax 2
    '';
  };

  security.acme = {
    acceptTerms = true;
    inherit email;
  };

  documentation.enable = false;

  system.stateVersion = "21.11";
  system.autoUpgrade.enable = false;

  #NOTE Disable unused protocal
  environment.etc = {
    "modprobe.d/CIS.conf".text = ''
      install tipc true
      install sctp true
      install dccp true
      install rds  true
    '';
  };

  #NOTE Block all USB
  services.usbguard = {
    enable = true;
    presentDevicePolicy = "block";
    presentControllerPolicy = "block";
    insertedDevicePolicy = "block";
    implictPolicyTarget = "block";
  };
})
