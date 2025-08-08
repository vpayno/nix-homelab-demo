# hosts/amd64/common/tools.nix
{
  pkgs,
  common,
  ...
}@args:
let
  debuggingTools = with pkgs; [
    file
    lsof
    net-tools
    strace
  ];

  hardwareTools = with pkgs; [
    cyme
    hdparm
    lshw
    lsscsi
    nvme-cli
    nvme-rs
    parted
    pciutils
    psmisc
    smartmontools
  ];

  packages = debuggingTools ++ hardwareTools;
in
{
  config = {
    environment = {
      systemPackages = packages;
    };
  };
}
