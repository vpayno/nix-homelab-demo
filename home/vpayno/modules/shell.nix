# home/vpayno/modules/shell.nix
{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      devbox
    ];
  };

  programs = {
    bash = {
      enable = true;
      bashrcExtra = ''
        # programs.bash.bashrcExtra
      '';
      enableCompletion = true;
      historyControl = [ "ignoreboth" ]; # "erasedups", "ignoredups", "ignorespace", "ignoreboth"
      initExtra = ''
        # programs.bash.initExtra
      '';
      logoutExtra = ''
        # programs.bash.logoutExtra
      '';
      profileExtra = ''
        # programs.bash.profileExtra
      '';
      # https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#:~:text=4.3.2%20The%20Shopt%20Builtin
      shellOptions = [
        "checkjobs"
        "checkwinsize"
        "extglob"
        "globstar"
        "histappend"
      ];
    };

    bashmount = {
      enable = true;
    };

    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
      syntaxes = {
        gleam = {
          src = pkgs.fetchFromGitHub {
            owner = "molnarmark";
            repo = "sublime-gleam";
            rev = "ff9638511e05b0aca236d63071c621977cffce38";
            hash = "sha256-94moZz9r5cMVPWTyzGlbpu9p2p/5Js7/KV6V4Etqvbo=";
          };
          file = "syntax/gleam.sublime-syntax";
        };
      };
      themes = {
        dracula = {
          src = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "sublime"; # Bat uses sublime syntax for its themes
            rev = "456d3289827964a6cb503a3b0a6448f4326f291b";
            sha256 = "sha256-8mCovVSrBjtFi5q+XQdqAaqOt3Q+Fo29eIDwECOViro=";
          };
          file = "Dracula.tmTheme";
        };
      };
      config = {
        map-syntax = [
          "*.conf:INI"
          ".*ignore:Git Ignore"
        ];
        pager = "less -FR";
        tabs = "4";
        theme = "auto:system"; # solorized auto:system
        theme-dark = "gruvbox-dark";
        theme-light = "gruvbox-light";
      };
    };

    broot = {
      enable = true;
      enableBashIntegration = true;
    };

    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      config = {
        global = {
          warn_timeout = "0";
        };
      };
      nix-direnv = {
        enable = true;
      };
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      colors = "auto";
      icons = "never";
      git = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      colors = {
        bg = "#1e1e1e";
        "bg+" = "#1e1e1e";
        fg = "#d4d4d4";
        "fg+" = "#d4d4d4";
      };
    };
  };
}
