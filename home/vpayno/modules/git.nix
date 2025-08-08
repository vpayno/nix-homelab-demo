# home/vpayno/modules/git.nix
{
  pkgs,
  ...
}:
{
  programs = {
    git = {
      enable = true;
      userName = "Victor Payno";
      userEmail = "vpayno@users.noreply.github.com";

      aliases = {
        tags = "tag --list | sort -V";
        ci = "commit";
        lc = "log ORIG_HEAD.. --stat --no-merges --color";
        llog = "log --date=local --color";
        lg-mc = "log --color=never --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit --decorate";
        lg = "log --color=auto --graph --pretty=format:'%Cred%<(8)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an> [%ce] %Creset%C(cyan)[gpg: %G?]%Creset' --abbrev-commit --decorate";
        lt = "tag --list -n1";
        lu = "!git lg $(git tag --list -n0 | tail -n1)..";
        lh = "log -n 10 --color --graph --pretty=format:'%Cred%<(8)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --decorate";
        cl = "log --pretty=format:'- %s' --abbrev-commit --decorate";
        co = "checkout";
        ds = "diff --staged";
        di = "diff";
        fetchall = "fetch -v --all";
        st = "status";
        amend = "commit --amend";
        rhr = "!f() { echo git push origin +HEAD~$1:$2; git push origin +HEAD~$1:$2; }; f";
        br = "branch";
        ab = "branch -av";
        nb = "!f() { git pull ; git checkout -B $1 && git push -u origin $1; }; f";
        fb = "!f() { git pull ; git fetch origin $1 && git branch -f $1 origin/$1 && git checkout $1; }; f";
        rb = "!f() { { git checkout main || git checkout master; } && git branch -D $1; git push origin :$1; }; f";
        log-fancy = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(cyan)<%an>%Creset' --abbrev-commit --date=relative --decorate";
        log-me = "!UN=$(git config user.name)&& git log --author=\"$UN\" --pretty=format:'%h %cd %s' --date=short";
        log-nice = "log --graph --decorate --pretty=oneline --abbrev-commit";
      };

      delta = {
        # sets core.pager
        enable = false; # https://github.com/dandavison/delta
        options = {
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-decoration-style = "none";
            file-style = "bold yellow ul";
          };
          features = "decorations";
          whitespace-error-style = "22 reverse";
        };
      };

      difftastic = {
        enable = true;
        background = "dark";
        color = "auto";
        display = "side-by-side-show-both"; # "side-by-side" "inline"
      };

      diff-so-fancy = {
        enable = false;
      };

      diff-highlight = {
        enable = false;
        pagerOpts = [
          "--tabs=4"
          "-RFX"
        ];
      };

      patdiff = {
        enable = false;
      };

      extraConfig = {
        push = {
          default = "matching";
          followTags = "true";
        };
        commit = {
          verbose = "true";
          gpgSign = "true";
        };
        "core" = {
          editor = "vim";
          # pager = "less | cat";
          logAllRefUpdates = "true";
          excludesfile = "~/.gitignore";
          whitespace = "trailing-space,space-before-tab";
          autocrlf = "false";
        };
        "apply" = {
          whitespace = "fix";
          color.ui = "true";
        };
      };
    };

    gitui = {
      enable = true;
    };

    lazygit = {
      enable = true;
    };
  };
}
