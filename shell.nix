let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    bashInteractive
    coreutils
    devbox
    git
    glow
    moreutils
    nixos-anywhere
    nixos-rebuild
    npins
    nvme-cli
    openssh
    parted
    runme
    tig
    tree
    tmux
  ];

  # usually not needed in nixos, needed everywhere else
  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  LANG = "en_US.UTF-8";

  shellHook = ''
    # cowsay exists here but it's not available in the shell to the user
    ${pkgs.cowsay}/bin/cowsay "Welcome to nix-shell!"
  '';
}
