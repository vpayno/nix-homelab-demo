# hosts/amd64/common/default.nix
{
  config,
  pkgs,
  ...
}@args:
{
  config = {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    programs = {
      bash = {
        shellInit = ''
          # programs.bash.shellInit
          # stdout from here can break nixos-anywhere/nixos-rebuild
        '';
        shellAliases = {
          ls = "ls -lhv";
          df = "df -h";
        };
        promptInit = ''
          # programs.bash.promptInit

          # Provide a nice prompt if the terminal supports it.
          if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
            PROMPT_COLOR="1;31m"
            ((UID)) && PROMPT_COLOR="1;32m"
            if [ -n "$INSIDE_EMACS" ]; then
              # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
              PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
            else
              PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
            fi
            if test "$TERM" = "xterm"; then
              PS1="\[\033]2;\h:\u:\w\007\]$PS1"
            fi
          fi
        '';
        logout = ''
          # programs.bash.logout

          printf '\e]0;\a'
        '';
        loginShellInit = ''
          # programs.bash.loginShellInit
        '';
        interactiveShellInit = ''
          # programs.bash.interactiveShellInit
        '';
        lsColorsFile = "${pkgs.dircolors-solarized}/ansi-dark";
        enableLsColors = true;
        completion = {
          enable = true;
        };
      };

      fzf = {
        fuzzyCompletion = true;
      };

      command-not-found = {
        enable = !config.programs.nix-index.enable;
      };
    };
  };
}
