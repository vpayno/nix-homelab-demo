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
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-conf,
      nvim-conf,
      ...
    }@inputs:
    let
      version = "v0.1.0";
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
          overlays = [
          ];
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
          nvim-conf = nvim-conf.packages.${system}.default;
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
      }
    );
}
