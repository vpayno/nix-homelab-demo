# hosts/amd64/common/hardware-defaults.nix
{
  config,
  lib,
  ...
}@args:
{
  hardware = {
    cpu = {
      amd = {
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };
}
