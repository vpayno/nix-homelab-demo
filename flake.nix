# flake.nix
{
  description = "My Nix/Nixos homelab configuration flake demo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-conf = {
      url = "github:vpayno/nix-treefmt-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-conf = {
      url = "github:vpayno/neovim-nix-nvf-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nixos-hardware = {
      type = "github";
      owner = "nixos";
      repo = "nixos-hardware";
      ref = "master";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:Misterio77/nix-colors";
    };

    phoenix = {
      url = "git+https://gitlab.com/celenityy/Phoenix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-conf,
      nvim-conf,
      disko,
      nixos-hardware,
      ...
    }@inputs:
    let
      version = "v0.1.0";

      myOverlays = import ./overlays.nix { };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          inherit (myOverlays.nixpkgs) overlays;
        };

        commonDevShellPkgs = with pkgs; [
          bashInteractive
          coreutils-full
          git
          glow
          home-manager
          moreutils
          nixos-anywhere
          nixos-rebuild
          npins
          nvme-cli
          openssh
          parted
          runme
          tig
          tmux
          tree
        ];
      in
      {
        formatter = treefmt-conf.formatter.${system};

        packages = {
          # make it easy to test overlay fixes
          inherit (pkgs)
            linux-firmware-20250509
            linux-firmware-20250613
            linux-firmware-20250621
            linux-firmware-20250627
            linux-firmware-20250708
            linux-firmware-20250725
            ;

          nvim-conf = nvim-conf.packages.${system}.default;
        };

        apps = {
          nvim = {
            type = "app";
            program = "${pkgs.lib.getExe self.packages.${system}.nvim-conf}";
            meta = {
              description = "pre-configured neovim editor";
              name = "nvim-${self.packages.${system}.nvim-conf.version}";
            };
          };
        };

        devShells = {
          default = pkgs.mkShell {
            packages = commonDevShellPkgs ++ [ self.packages.${system}.nvim-conf ];

            GREETING = "Starting nix develop shell ${version}...";

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "$GREETING"
            '';
          };
        };

        homeConfigurations."vpayno" = inputs.home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs pkgs;
          };
          modules = [
            ./home/vpayno/headless.nix
          ];
        };
      }
    )
    // (
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          inherit (myOverlays.nixpkgs) overlays;
        };
      in
      {
        nixosConfigurations = {
          build1 = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              hostname = "build1";
              domainname = "local";
              hostId = "9d3ed2e4"; # head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
              inherit
                self
                inputs
                system
                ;
            };
            modules = [
              ./overlays.nix
              nixos-hardware.nixosModules.framework-13-7040-amd
              disko.nixosModules.disko
              ./hosts/amd64/build1/default.nix
            ];
          };
        };
      }
    );
}
