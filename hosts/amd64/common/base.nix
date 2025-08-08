# hosts/amd64/common/default.nix
{
  config,
  pkgs,
  lib,
  ...
}@args:
{
  config = {
    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };

    console = {
      enable = true;
      keyMap = lib.mkDefault "us";
      useXkbConfig = true;
    };

    services = {
      # Configure keymap in X11
      xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # List services that you want to enable:
      openssh.enable = true;
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment = {
      systemPackages =
        map pkgs.lib.lowPrio (
          with pkgs;
          [
            curl
          ]
        )
        ++ (with pkgs; [
          ansifilter
          bashInteractive
          binutils
          btop
          coreutils-full
          git
          gnused
          jaq
          killall
          moreutils
          nh
          nix-output-monitor
          nvd
          nvdtools
          openssh
          tmux
          tree
          vim
          wget
        ]);
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    programs = {
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      nix-index = {
        enable = true;
        enableBashIntegration = true;
      };
    };

    nix = {
      gc = {
        automatic = !config.services.nix-serve.enable;
        dates = "weekly";
        options = "--delete-older-than 90d";
      };

      optimise = {
        automatic = true;
        dates = [ "03:45" ];
      };

      settings = {
        allowed-users = [
          "root"
          "@nixbld"
          "@wheel"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
        max-jobs = if config.services.nix-serve.enable then "auto" else 0;
        auto-optimise-store = config.nix.optimise.automatic;
        substituters = [
          "https://build1/"
          # "https://cache.nixos.org/"  # added automatically
        ];
        trusted-substituters = [
          "https://build1/"
        ];
        trusted-public-keys = [
          "build1-1:Xdd9mwabeDikLVsQqnYs/G2co04AQ2PpfBriVIYapPB="
          # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="  # added automatically
        ];
      };

      # first line is intentionally blank
      extraOptions = ''

        #
        # nix.extraOptions
        #

        # build-users-group = nixbld

        experimental-features = nix-command flakes ca-derivations cgroups fetch-closure pipe-operators

        keep-outputs = true       # Nice for developers
        keep-derivations = true   # Idem

        # run GC when running out of space
        min-free = ${toString (100 * 1024 * 1024)} # 100GB
        max-free = ${toString (1024 * 1024 * 1024)} # 1TB

        # allow builders to download directly
        builders-use-substitutes = true
      ''
      + (
        if !config.services.nix-serve.enable then
          ''

            # use remote builders
            builders = @/etc/nix/machines
          ''
        else
          ''

            # nix-serve, automatically sign local builds
            secret-key-files = /etc/nix/cache-priv-key.pem
          ''
      );
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
  };
}
