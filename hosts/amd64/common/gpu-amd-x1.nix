# hosts/amd64/common/gpu-amd_x1.nix
#
# https://journix.dev/posts/gaming-on-nixos/
#
{
  config,
  lib,
  pkgs,
  ...
}@args:
{
  config = {
    boot = {
      initrd = {
        kernelModules = [
          "amdgpu"
        ];
      };

      extraModprobeConfig = ''
        # options nouveau modeset=0
        # options nvidia ...
      '';

      extraModulePackages = [
        config.boot.kernelPackages.amdgpu-i2c
      ];

      blacklistedKernelModules = [
        # "amdgpu"
      ];

      kernelParams = [
        # "amdgpu.dcdebugmask=0x10" # disable panel self-refresh (PSR)
        # "module_blacklist=nouveau"
      ];
    };

    environment = {
      systemPackages =
        with pkgs;
        [
          clinfo
          furmark
          gpu-viewer
          lact
          memtest_vulkan
          vkmark
          vulkan-tools
        ]
        ++ (with pkgs; [
          amdgpu_top
          nvtopPackages.amd
          radeontop
          # rgp
          rocmPackages.rocm-smi
          umr
        ]);
    };

    hardware = {
      amdgpu = {
        amdvlk = {
          enable = true;
          support32Bit = {
            enable = true;
          };
          settings = {
            AllowVkPipelineCachingToDisk = 1;
            EnableVmAlwaysValid = 1;
            IFH = 0;
            IdleAfterSubmitGpuMask = 1;
            ShaderCacheMode = 1;
          };
        };
        opencl = {
          enable = true;
        };

        initrd = {
          enable = true;
        };
      };

      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          amdvlk
          driversi686Linux.amdvlk
        ];
      };
    };

    services = {
      xserver = {
        videoDrivers = [
          "amdgpu"
        ];
      };
    };

    # systemd = {
    #   sleep = {
    #     extraConfig = ''
    #       AllowHibernation=no
    #       AllowSuspend=yes
    #       AllowSuspendThenHibernate=no
    #       AllowHybridSleep=no
    #     '';
    #   };
    # };
  };
}
