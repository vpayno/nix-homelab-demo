# hosts/amd64/build1/boot.nix
{
  config,
  pkgs,
  ...
}@args:
{
  config = {
    boot = {
      # 			0 (KERN_EMERG)		system is unusable
      # 1 (KERN_ALERT)		action must be taken immediately
      # 2 (KERN_CRIT)		critical conditions
      # 3 (KERN_ERR)		error conditions
      # 4 (KERN_WARNING)	warning conditions
      # 5 (KERN_NOTICE)		normal but significant condition
      # 6 (KERN_INFO)		informational
      # 7 (KERN_DEBUG)		debug-level messages
      consoleLogLevel = 6; # default is 4

      loader = {
        timeout = 30;

        systemd-boot = {
          enable = true;
          configurationLimit = 7;

          memtest86 = {
            enable = true;
          };

          netbootxyz.enable = true;

          edk2-uefi-shell.enable = true;
        };

        efi = {
          # efiSysMountPoint = "/boot/efi"; # /boot
          canTouchEfiVariables = true;
        };

        grub = {
          enable = false;
          configurationLimit = 7;

          efiSupport = pkgs.lib.mkForce true;
          efiInstallAsRemovable = if config.boot.loader.efi.canTouchEfiVariables then false else true;

          # gfxmodeEfi = "1024x768"; # "3440x1440"

          zfsSupport = true;

          useOSProber = true;
          device = "nodev";
          devices = [
            "nodev"
          ];

          memtest86 = {
            enable = true;
            # params = "console=ttyS0,115200n8";
          };

          # extraGrubInstallArgs = [ "--bootloader-id=${host}" ];
          # configurationName = "${host}";

          extraEntriesBeforeNixOS = false;
          extraEntries = ''
            if [ ''${grub_platform} == "efi" ]; then
              menuentry 'UEFI Firmware Settings' --id 'uefi-firmware' {
                echo "Entering firmware setup utility..."
                fwsetup
                echo ""
                echo "If you see this, fwsetup isn't supported on your system."
                echo ""
              }
            fi
            menuentry "System restart" {
              echo "System rebooting..."
              reboot
              echo ""
              echo "If you see this, reboot isn't supported on your system."
              echo ""
            }
            menuentry "System shutdown" {
              echo "System shutting down..."
              halt
              echo ""
              echo "If you see this, halt isn't supported on your system."
              echo ""
            }
          '';
        };
      };

      initrd = {
        # luks.devices."luks-75088708-d83a-41bb-8e65-4009cc6d89ab".device = "/dev/disk/by-uuid/75088708-d83a-41bb-8e65-4009cc6d89ab";

        verbose = true;

        kernelModules = [
          "amdgpu"
        ];

        availableKernelModules = [
          "amdgpu"
          "nvme"
          "xhci_pci"
          "thunderbolt"
          "usb_storage"
          "sd_mod"
        ];
      };

      kernelModules = [
        "kvm-amd"
      ];

      blacklistedKernelModules = [
      ];

      extraModulePackages = with config.boot.kernelPackages; [
      ];

      postBootCommands = ''
        ${pkgs.lib.getExe pkgs.cowsay} 'Hello NixOS!'

        # maximum dimness
        ${pkgs.coreutils-full}/bin/printf "Setting screen brightness to %s.\n" "0%/lowest setting"
        ${pkgs.lib.getExe pkgs.brightnessctl} set 0%

        # cmdline set this to 10m, setting it to 9m here
        ${pkgs.coreutils-full}/bin/printf "Setting screen console blanking timeout to %d minutes.\n" 9
        ${pkgs.util-linux.bin}/bin/setterm --term=linux --blank=9
      '';

      kernelParams = [
        # "console=ttyS0,115200n8"

        "consoleblank=600"
        "memtest=2"

        # "amdgpu.abmlevel=0"
        #
        # "iommu=on"
        # "amd_iommu=on"
        # "iommu=pt"
        # "initcall_blacklist=sysfb_init"
        # "video=simplefb:off"
        #
        # "amdgpu.power_dpm_state=performance"
        # "amdgpu.power_dpm_force_performance_level=high"
        # "amdgpu.gpu_recovery=1"
        # "amd_pstate=active"
        # "rtc_cmos.use_acpi_alarm=1"
        # "pcie_aspm=off"
        #
        # "amdgpu.sg_display=0"

        "amd_iommu=on"
        "amdgpu.abmlevel=0"
      ];

      kernel.sysctl = {
        "net.ipv4.conf.all.arp_filter" = true;
      };

      tmp = {
        useTmpfs = false;
        tmpfsSize = "25%";
      };

      binfmt = {
        emulatedSystems = [
          "aarch64-linux"
          "riscv64-linux"
        ];
      };

      plymouth.enable = false; # boot splash
    };

    systemd = {
      tmpfiles = {
        rules = [
        ];
      };
    };
  };
}
