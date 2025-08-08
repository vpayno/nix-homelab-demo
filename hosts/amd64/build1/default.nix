# hosts/amd64/build1/default.nix
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}@args:
{
  imports = [
    # Include the results of the hardware scan.
    ../../../disklayouts/nvme-zfs-encrypted-root.nix

    ./hardware-configuration.nix
    ./boot.nix

    inputs.nixos-facter-modules.nixosModules.facter
    { config.facter.reportPath = ./facter.json; }

    inputs.home-manager.nixosModules.home-manager

    ../common/gpu-amd-x1.nix
    ../common/laptop.nix

    ../common/base.nix
    ../common/hardware-defaults.nix
    ../common/networking.nix
    ../common/security.nix
    ../common/tools.nix
    ../common/shell.nix
    ../common/users.nix

    ../common/docker.nix

    ../common/binary-cache.nix
  ];

  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      users = {
        vpayno = import ../../../home/vpayno/headless.nix;
      };
    };
  };
}
