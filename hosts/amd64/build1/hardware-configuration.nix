# hosts/amd64/build1/hardware-configuration.nix
{
  config,
  lib,
  pkgs,
  modulesPath,
  hostname ? "build1",
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {
    # fileSystems = {
    #   "/" = {
    #     device = "/dev/disk/by-uuid/088a98e2-8e52-4271-b3f7-066373dba0d9";
    #     fsType = "xfs";
    #   };
    #   "/boot" = {
    #     device = "/dev/disk/by-uuid/DCDA-C65F";
    #     fsType = "vfat";
    #     options = [
    #       "fmask=0077"
    #       "dmask=0077"
    #     ];
    #   };
    # };

    # swapDevices = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkForce true;
    # networking.interfaces.enp195s0f3u1.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
      config = {
        allowBroken = false;
        allowUnfree = true;
      };
    };

    hardware = {
      cpu = {
        amd = {
          updateMicrocode = true;
          sev.enable = true; # secure encrypted virtualization https://github.com/AMDESE/AMDSEV
          sevGuest.enable = true;
        };
        x86.msr.enable = true;
      };

      ksm.enable = true; # enable hypervisor memory dedupe

      mcelog.enable = true;

      acpilight.enable = true;

      nitrokey.enable = true;

      sensor = {
        hddtemp = {
          enable = false;
          drives = [
            "/dev/sd[a-z]+[0-9]+"
          ];
          unit = "C";
        };
      };
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "performance"; # performance powersave userspace ondemand

    services = {
      acpid = {
        enable = true;
      };

      fprintd = {
        enable = true; # enable fingerprint reader
      };

      fstrim.enable = true;

      fwupd = {
        enable = true;
      };

      power-profiles-daemon = {
        enable = true;
      };

      tlp = {
        enable = !config.services.power-profiles-daemon.enable;
      };

      udev = {
        enable = true;
        extraRules = ''
          # prevent wakeup in backpack
          SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled", ATTR{driver/1-1.1.1.4/power/wakeup}="disabled"
          SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled", ATTR{driver/1-1.1.1.4/power/wakeup}="disabled"

          # google titan hw key
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="18d1|096e", ATTRS{idProduct}=="5026|0858|085b", TAG+="uaccess"

          # yubikey hw key
          SUBSYSTEM=="usb", ENV{ID_MODEL_ID}="0407", ENV{ID_VENDOR_ID}="1050", TAG+="systemd", SYMLINK="yubikey"
        '';
      };
    };

    environment = {
      systemPackages = with pkgs; [
        lm_sensors
      ];
    };
  };
}
