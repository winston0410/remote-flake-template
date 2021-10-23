({ pkgs, lib, ... }: {
 services.restic.server = {
    enable = true;
    listenAddress = "0.0.0.0:44444";
    extraFlags = ["--no-auth"];
 };   
})
