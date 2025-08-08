# home/vpayno/headless.nix
{
  inputs,
  config,
  context,
  pkgs,
  ...
}@args:
{
  imports = [
    args.inputs.nix-colors.homeManagerModules.default
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/tmux.nix
  ];

  colorScheme = args.inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

  home = {
    stateVersion = "25.05";

    username = "vpayno";
    homeDirectory = "/home/vpayno";

    # targets.genericLinux.enable = true; # for non-nixos

    packages = with pkgs; [
    ];

    sessionVariables = {
      EDITOR = "vim";
    };

    file = {
    };
  };

  programs = {
  };
}
