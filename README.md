# nix-homelab-demo

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

## Installing NixOS

- Boot from USB disk
- Set root password
- Run installer

### Testing/Only Applying Disk Layout

```text
scp ./disklayouts/nvme-zfs-encrypted-root.nix root@build1:/tmp/

ssh -t root@build1 sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/nvme-zfs-encrypted-root.nix
```

### Test configuration with nix eval

```bash
nix --extra-experimental-features 'nix-command flakes' eval --raw '.#nixosConfigurations."build1".config.system.build.toplevel.drvPath' --show-trace
```

### Collecting Hardware Information

```bash
ssh root@build1 'nix --extra-experimental-features "flakes nix-command" run github:numtide/nixos-facter' > hosts/amd64/build1/facter.json
```

### Push SSH Key

```bash
ssh-copy-id -i "${HOME}/.ssh/id_ecdsa" root@build1
```

### Run Installer

Use `--disko-mode mount` if you need to resume the initial nixos-installation
without destroying the installation and starting over.

```bash
nix run --show-trace github:nix-community/nixos-anywhere -- --flake .#build1 --target-host root@build1 --ssh-option "IdentityFile=${HOME}/.ssh/id_ecdsa" --ssh-option "PreferredAuthentications=publickey" --ssh-option "PubkeyAuthentication=yes" --ssh-option "Compression=yes" --ssh-option "ControlMaster=auto" --ssh-option "ControlPath=${HOME}/.ssh/control:%h:%p:%r" --ssh-option "ControlPersist=10m" --ssh-option "ServerAliveInterval=60" --ssh-option "ServerAliveCountMax=3" --ssh-option "ForwardAgent=no" --disko-mode disko
```

### Updates post installation

If flake repo is public:

```text
$ ssh -t -A build1 'tmux a || tmux'

$ nixos-rebuild list-generations
Generation  Build-date           NixOS version           Kernel   Configuration Revision  Specialisation
1 current   2025-03-30 11:00:09  25.05.20250327.5e5402e  6.12.20                          *

$ sudo nixos-rebuild switch --flake github:vpayno/nix-homelab-demo#build1
building the system configuration...
activating the configuration...
setting up /etc...
reloading user units for vpayno...
restarting sysinit-reactivation.target
the following new units were started: NetworkManager-dispatcher.service, sysinit-reactivation.target, systemd-tmpfiles-resetup.service
Done. The new configuration is /nix/store/x5a9kgxa1g3d89dj48b4k9pp8ilf0sg6-nixos-system-build1-25.05.20250327.5e5402e

$ sudo reboot
```

If flake repo is private:

```text
$ ssh -t -A build1 'tmux a || tmux'

$ ssh git@github.com
PTY allocation request failed on channel 0
Hi vpayno! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.

$ nixos-rebuild list-generations
Generation  Build-date           NixOS version           Kernel   Configuration Revision  Specialisation
1 current   2025-03-30 11:00:09  25.05.20250327.5e5402e  6.12.20                          *

# using `--preserve-env` to share `SSH_AUTH_SOCK` with the root user
$ sudo --preserve-env nixos-rebuild switch --flake git+ssh://git@github.com/vpayno/nix-homelab-demo#build1
building the system configuration...
activating the configuration...
setting up /etc...
reloading user units for vpayno...
restarting sysinit-reactivation.target
the following new units were started: NetworkManager-dispatcher.service, sysinit-reactivation.target, systemd-tmpfiles-resetup.service
Done. The new configuration is /nix/store/x5a9kgxa1g3d89dj48b4k9pp8ilf0sg6-nixos-system-build1-25.05.20250327.5e5402e

$ sudo reboot
```

Remotely without first sshing into the server. This is the preferred method
because you can update locks, make changes, and push to the server from the same
shell without pushing changes to the git remote first.

```text
# this step is needed if running commands from a non-nixos host
$ nix shell nixpkgs#nixos-rebuild

$ ssh build1 nixos-rebuild list-generations
Generation  Build-date           NixOS version           Kernel   Configuration Revision  Specialisation
1 current   2025-03-30 11:00:09  25.05.20250327.5e5402e  6.12.20                          *

$ nix flake update
warning: Git tree '/home/vpayno/git_vpayno/nix-homelab-demo' is dirty
warning: updating lock file '/home/vpayno/git_vpayno/nix-homelab-demo/flake.lock':
• Updated input 'nixpkgs':
    'github:nixos/nixpkgs/5e5402ecbcb27af32284d4a62553c019a3a49ea6?narHash=sha256-gWd4urRoLRe8GLVC/3rYRae1h%2BxfQzt09xOfb0PaHSk%3D' (2025-03-27)
  → 'github:nixos/nixpkgs/52faf482a3889b7619003c0daec593a1912fddc1?narHash=sha256-6hl6L/tRnwubHcA4pfUUtk542wn2Om%2BD4UnDhlDW9BE%3D' (2025-03-30)
warning: Git tree '/home/vpayno/git_vpayno/nix-homelab-demo' is dirty

$ nix run nixpkgs#nixos-rebuild -- switch --build-host root@build1 --target-host root@build1 --use-substitutes --flake .#build1
building the system configuration...
copying 52 paths...
copying path '/nix/store/6wryj87qhbr1zs5lyi7gi0mq2nk0cq6q-linux-6.12.21' to 'ssh://root@build1'...
copying path '/nix/store/43x21c0sphbdxi6vhbrgz44zbivzdyjf-hwdb.bin' to 'ssh://root@build1'...
copying path '/nix/store/9qd2bi98nh9yd4axm9zr16zln01w62q3-source' to 'ssh://root@build1'...
copying path '/nix/store/7kqivr835y42d9aw3ykpg2a2qaqfya74-webkitgtk-2.48.0+abi=4.1' to 'ssh://root@build1'...
copying path '/nix/store/fb73aw0pv0f3shay72cbinsh0nypzvvn-system-shutdown' to 'ssh://root@build1'...
copying path '/nix/store/7raygdcfgy1q8vqciijnz4s57wahy5gv-nix-2.24.13-doc' to 'ssh://root@build1'...
copying path '/nix/store/gk4jv27pamdcjjkwra1cj4pmj1afzw1b-nixos-configuration-reference-manpage' to 'ssh://root@build1'...
copying path '/nix/store/ig5gry835d3rc9cw6n7gwlb704yfd5gs-zfs-kernel-2.3.1-6.12.21' to 'ssh://root@build1'...
copying path '/nix/store/j6prplfr5mkgbv2gakgz7ks8xqkhk29s-nix-2.24.13-man' to 'ssh://root@build1'...
copying path '/nix/store/a0sm6mxxb229zv7a42fh9yfbvgdwwz3w-issue' to 'ssh://root@build1'...
copying path '/nix/store/m8z1ab78vdh237bciw0dycdbd8ayilbb-nix-2.24.13' to 'ssh://root@build1'...
copying path '/nix/store/q19172ci46d1p5s9b5aa71qs1fnw0wjw-nix.conf' to 'ssh://root@build1'...
copying path '/nix/store/ja92w12ljbw6yrb3y5n5bkv962fv9r7x-system-generators' to 'ssh://root@build1'...
copying path '/nix/store/r84nqavf7jsxn4xdpp57b8f30b51853d-linux-6.12.21-modules' to 'ssh://root@build1'...
copying path '/nix/store/q1602qdsv1nppbc349sm4rm9vs9p3l8y-NetworkManager-openconnect-1.2.10' to 'ssh://root@build1'...
copying path '/nix/store/934k43485hghqc1n6ab6dms4nh17xc27-etc-nix-registry.json' to 'ssh://root@build1'...
copying path '/nix/store/s8rgagax3vxd95q305rmgj76qi09iscs-systemd-boot' to 'ssh://root@build1'...
copying path '/nix/store/6iizv3kvwf7afkwdvhyvncr0nd4w1286-nixos-manual-html' to 'ssh://root@build1'...
copying path '/nix/store/xnljxbqmpwyqf82ba85qq52iacb49zvs-udev-rules' to 'ssh://root@build1'...
copying path '/nix/store/vqkfcqq2wgk7kmkz8dbwqr1n1vi7kyln-nixos-version' to 'ssh://root@build1'...
copying path '/nix/store/q91gh1m7vavfq6h75a58538dwpsq8vb8-user-generators' to 'ssh://root@build1'...
copying path '/nix/store/00f5lx20vk3nkvfyg5cf0zpp3h24z1y7-unit-script-nix-gc-start' to 'ssh://root@build1'...
copying path '/nix/store/6rfjp4bpbr96an4ldkzc0qybplf53g2s-unit-nix-optimise.service' to 'ssh://root@build1'...
copying path '/nix/store/y4qxw8rihscwhr7kh0d1a207lblc2dwf-install-systemd-boot.sh' to 'ssh://root@build1'...
copying path '/nix/store/gcsbdi66v32x0xa1n90hksg2bdzs58sh-nixos-option' to 'ssh://root@build1'...
copying path '/nix/store/2488c3zrxahyq21r5afk6x9wvl5fj100-X-Restart-Triggers-nix-daemon' to 'ssh://root@build1'...
copying path '/nix/store/11q5fasqj4k9f6465qxyqm5459zqkzzn-nixos-help' to 'ssh://root@build1'...
copying path '/nix/store/a9p9v72akrscrcmb7bq9rjsyazafa02g-tmpfiles.d' to 'ssh://root@build1'...
copying path '/nix/store/rdpwz6cq2d2blj3naqgh8pyn9l770zj7-nixos-rebuild' to 'ssh://root@build1'...
copying path '/nix/store/rivk0x8q7qy3ll3hv38r2k5lbfdh9q72-etc-os-release' to 'ssh://root@build1'...
copying path '/nix/store/qgqzhadb4adgkrm4d2hak7n8pika0m6d-shutdown-ramfs-contents.json' to 'ssh://root@build1'...
copying path '/nix/store/nk8mv8nypvdbdyrd426ipxfq9j23hwp4-linux-6.12.21-modules-shrunk' to 'ssh://root@build1'...
copying path '/nix/store/sv08h76471q8jsaisk4fh2kf1yr630ls-unit-nix-gc.service' to 'ssh://root@build1'...
copying path '/nix/store/jnm43jkhx6a2fghicpg3r22dgpg66v55-unit-nix-daemon.service' to 'ssh://root@build1'...
copying path '/nix/store/s2cxi2ja7ln0i31lahg5n543df7cc608-nixos-help' to 'ssh://root@build1'...
copying path '/nix/store/84qwbgp94mck6zrx873z4nnj3mxvl57y-X-Restart-Triggers-systemd-tmpfiles-resetup' to 'ssh://root@build1'...
copying path '/nix/store/l9d6q0jnmm9sf5d2ih3ahd6a76vwk61d-unit-systemd-tmpfiles-resetup.service' to 'ssh://root@build1'...
copying path '/nix/store/lsnxpkm04z4in99q6wqgnlh5ja1lwmql-unit-generate-shutdown-ramfs.service' to 'ssh://root@build1'...
copying path '/nix/store/k505nydwvb0wwzsamb2km7xwrmd3838q-initrd-linux-6.12.21' to 'ssh://root@build1'...
copying path '/nix/store/0fzds33367vv924qabv2rbhcwcaysa20-system-path' to 'ssh://root@build1'...
copying path '/nix/store/0gdcp1k2x9y366aryjqy83f30kvrag2l-X-Restart-Triggers-systemd-udevd' to 'ssh://root@build1'...
copying path '/nix/store/9r34higcglcjs3rbbj5q30aa72nh4rgk-X-Restart-Triggers-polkit' to 'ssh://root@build1'...
copying path '/nix/store/dhm584pv6b30gkp74ws5hl5gymanz7lz-dbus-1' to 'ssh://root@build1'...
copying path '/nix/store/d4qmx5g580m3mrx4f1wqmap88fww3abx-unit-systemd-udevd.service' to 'ssh://root@build1'...
copying path '/nix/store/k79wcbcsz88snv80yd4bdl2q6z5cqqcm-unit-polkit.service' to 'ssh://root@build1'...
copying path '/nix/store/jq46wdv7wa4zj292l1p4hlksh1nhvyh6-X-Restart-Triggers-dbus' to 'ssh://root@build1'...
copying path '/nix/store/hbzqmmzivsqbpk8hfjqj1ddbyc867yv7-unit-dbus.service' to 'ssh://root@build1'...
copying path '/nix/store/zpcnwbdhd1dpq70v7lyhhk9fph9b07sx-unit-dbus.service' to 'ssh://root@build1'...
copying path '/nix/store/w2q7dyzvqrivwvkk39c8gaswjzszhps6-system-units' to 'ssh://root@build1'...
copying path '/nix/store/z16h39l0bpnqwa9gydh12gss5dlhg64b-user-units' to 'ssh://root@build1'...
copying path '/nix/store/i9f59zgd9kgadkz6xmm141i6v6mdc5hv-etc' to 'ssh://root@build1'...
copying path '/nix/store/wm4y6kq2i1m14i99f1ia2x726brda5hj-nixos-system-build1-25.05.20250330.52faf48' to 'ssh://root@build1'...
Shared connection to 192.168.1.101 closed.
Shared connection to 192.168.1.101 closed.
stopping the following units: systemd-tmpfiles-resetup.service
activating the configuration...
setting up /etc...
reloading user units for root...
reloading user units for vpayno...
restarting sysinit-reactivation.target
reloading the following units: dbus.service
restarting the following units: nix-daemon.service, polkit.service, systemd-udevd.service
starting the following units: systemd-tmpfiles-resetup.service
the following new units were started: NetworkManager-dispatcher.service
Shared connection to 192.168.1.101 closed.
Done. The new configuration is /nix/store/wm4y6kq2i1m14i99f1ia2x726brda5hj-nixos-system-build1-25.05.20250330.52faf48

$ ssh build1 nixos-rebuild list-generations
Generation  Build-date           NixOS version           Kernel   Configuration Revision  Specialisation
2 current   2025-03-31 21:39:59  25.05.20250330.52faf48  6.12.21                          *
1           2025-03-30 11:00:09  25.05.20250327.5e5402e  6.12.20                          *

$ ssh root@build1 reboot

$ ssh build1 uptime
 21:46:17  up   0:02,  1 user,  load average: 0.11, 0.09, 0.04

$ git add flake.lock

$ git commit -m 'nix: update locks'
[main 03832c9] nix: update locks
 1 file changed, 3 insertions(+), 3 deletions(-)

$ git push origin main
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 8 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 1.54 KiB | 1.54 MiB/s, done.
Total 6 (delta 4), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (4/4), completed with 3 local objects.
To github.com:vpayno/nix-homelab-demo.git
   4a73130..03832c9  main -> main

$ exit
```
