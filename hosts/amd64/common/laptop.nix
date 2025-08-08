# hosts/amd64/common/laptop.nix
{
  config,
  pkgs,
  ...
}@args:
let
  scripts = {
    batteryCheckAcpi = pkgs.writeShellApplication {
      name = "battery-check-acpi";
      runtimeInputs = with pkgs; [
        acpi
      ];
      text = ''
        acpi "$@"
      '';
    };
    batteryCheckUpower = pkgs.writeShellApplication {
      name = "battery-check-upower";
      runtimeInputs = with pkgs; [
        gnugrep
        upower
      ];
      text = ''
        upower -i "$(upower -e | grep '/battery')" | grep --color=never -E "state|to full|to empty|percentage"
      '';
    };
  };
in
{
  config = {
    environment = {
      systemPackages =
        with pkgs;
        [
          acpi
        ]
        ++ (with scripts; [
          batteryCheckAcpi
          batteryCheckUpower
        ]);
    };

    services = {
      upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 25; # 20%
        percentageCritical = 15; # 5%
        percentageAction = 10; # 2%
        criticalPowerAction = "PowerOff";
      };
      cpupower-gui = {
        enable = config.services.xserver.enable;
      };
    };
  };
}
