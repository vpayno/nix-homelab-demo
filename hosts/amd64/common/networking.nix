# hosts/amd64/common/networking.nix
{
  config,
  pkgs,
  lib,
  ...
}@args:
{
  config = {
    networking = {
      hostName = "${args.hostname}";
      hostId = "${args.hostId}";
      #wireless.enable = true;
      useDHCP = pkgs.lib.mkDefault true;

      # Configure network proxy if necessary
      # proxy = {
      #   default = "http://user:password@proxy:port/";
      #   noProxy = "127.0.0.1,localhost,internal.domain";
      # };

      # Enable networking
      networkmanager.enable = true;

      usePredictableInterfaceNames = lib.mkForce true;

      timeServers = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];

      # Open ports in the firewall. Or disable the firewall altogether.
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
          80
        ];
        allowedUDPPorts = [ ];
        checkReversePath = "loose";
      };
    };
  };
}
