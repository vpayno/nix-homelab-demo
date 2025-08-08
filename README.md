# nix-homelab-demo

[![Markdown Checks](https://github.com/vpayno/nix-homelab-conf/actions/workflows/markdown.yaml/badge.svg?branch=main)](https://github.com/vpayno/nix-homelab-conf/actions/workflows/markdown.yaml)

My Nix/Nixos homelab demo configuration repo.

## nix-shell & nix develop

Including `shell.nix` for `nix-shell for when flakes aren't enabled.

Otherwise, I'm using `nix develop` with `direnv`.

### direnv

Using `direnv`, `nix-direnv` and `devbox` to setup automatic `devShell` loading.

Use `direnv allow` to allow loading of the `.envrc` file or `direnv deny` to
block it.

Use `direnv reload` to reload the shell or switch shell types or abort loading
`.envrc`.

```text
# direnv reload
direnv: loading ~/git_vpayno/nix-homelab-demo/.envrc
direnv: which environment would you like to use?
> nix develop .#default
  abort
```
