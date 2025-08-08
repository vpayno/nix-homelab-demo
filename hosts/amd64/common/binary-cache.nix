# hosts/amd64/common/binary-cache.nix
#
# test:
#   nix-build '<nixpkgs>' -A pkgs.hello
#   curl -sS http://build1/nix-cache-info
#   curl -sS http://build1/wvfhs8k86740b7j3h1iss94z7cb0ggj1.narinfo
#   curl -sS https://build1/wvfhs8k86740b7j3h1iss94z7cb0ggj1.narinfo
#   nix path-info -r /nix/store//wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2 --store https://build1/
#   curl -sS https://build1/$(readlink -f $(which bash) | cut -c12-43).narinfo
#   for i in {1..10}; do curl -sS http://build1/nix-cache-info; done
#
#   hash=$(nix-build '<nixpkgs>' -A pkgs.hello | awk -F '/' '{print $4}' | awk -F '-' '{print $1}')
#   curl -sS "http://build1/$hash.narinfo" | grep "Sig: "
#
#   nix store verify --store https://build1 --trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= build1:Xdd9mwabeDikLVsQqnYs/G2co04AQ2PpfBriVIYapPB=' /nix/store/l7g9xpban2f3c7iqinx6n6zwzaz83dsm-nvf-with-helpers && echo OK
#
#   nix store copy-sigs --all -s https://cache.nixos.org
#   nix store copy-sigs --all -s https://build1
#
{
  config,
  pkgs,
  ...
}@args:
let
  scripts = {
    nixServeCreateKeys = pkgs.writeShellApplication {
      name = "nix-store-generate-cache-keys";
      runtimeInputs = with pkgs; [
        coreutils-full
        cowsay
        nix
      ];
      text = ''
        [[ -f /etc/nix/cache-priv-key.pem ]] && exit 0
        cowsay "Generating private/public keys for nix-serve..."
        nix-store --generate-binary-cache-key ${args.hostname}.${args.domainname} /etc/nix/cache-priv-key.pem /etc/nix/cache-pub-key.pem
        chmod -v 0440 /etc/nix/cache-priv-key.pem
        chgrp -v nixbld /etc/nix/cache-priv-key.pem
        printf "Done\n"
      '';
    };
  };
in
{
  imports = [
  ];

  config = {
    nix = {
      settings = {
        # list of extra features
        system-features = [
          # "benchmark" # automatically included
          # "big-parallel" # automatically included
          # "kvm" # automatically included
          # "nixos-test" # automatically included
        ];
      };

      sshServe = {
        enable = true;
        trusted = true;
        write = true;
        protocol = "ssh"; # "ssh-ng"
        keys = [
        ];
      };
    };

    services = {
      harmonia = {
        enable = true;
        signKeyPaths = [
          "/etc/nix/cache-priv-key.pem"
        ];
        settings = {
          bind = "[::]:5200";
          # bind = "unix:/run/harmonia/socket"
          workers = 4;
          max_connection_rate = 256; # per worker
          priority = 50; # advertised in /nix-cache-info
        };
      };

      nar-serve = {
        enable = false;
        port = 8383;
        domain = "${args.domainname}";
        cacheURL = "http://${args.hostname}.${args.domainname}";
      };

      nix-serve = {
        enable = false;
        package = pkgs.nix-serve-ng;
        port = 5100;
        bindAddress = "0.0.0.0";
        openFirewall = true;
        secretKeyFile = "/etc/nix/cache-priv-key.pem";
      };

      nginx = {
        enable = true;
        recommendedProxySettings = true;
        upstreams = {
          nix-binary-cache = {
            extraConfig = ''
              keepalive 16;
            '';
            servers = {
              # fqdn:port = {}
              # "${args.hostname}.${args.domainname}:${toString config.services.nix-serve.port}" = {
              #   weight = 5;
              #   backup = false;
              # };
              "${args.hostname}.${args.domainname}:${toString (builtins.elemAt (builtins.split "^.*:" config.services.harmonia.settings.bind) 2)}" =
                {
                  weight = 5;
                  backup = false;
                };
            };
          };
          nix-nar-serve = {
            extraConfig = ''
              keepalive 16;
            '';
            servers = {
              # fqdn:port = {}
              "${args.hostname}.${args.domainname}:${toString config.services.nar-serve.port}" = {
                weight = 5;
                backup = false;
              };
            };
          };
        };
        virtualHosts = {
          "${args.hostname}.${args.domainname}" = {
            serverName = "${args.hostname}";
            serverAliases = [
              "${args.hostname}.${args.domainname}"
              "cache.${args.domainname}"
              "cache"
            ];
            locations = {
              "/" = {
                proxyPass = "http://nix-binary-cache";
              };
            };
          };
          "nar-serve.${args.domainname}" = {
            serverName = "nar-serve";
            serverAliases = [
              "nar-serve.${args.domainname}"
            ];
            locations = {
              "/" = {
                proxyPass = "http://nix-nar-serve";
              };
            };
          };
        };
      };
    };

    systemd = {
      services = {
        generate-nix-cache-key = {
          wantedBy = [
            "multi-user.target"
          ];
          requiredBy = [
            "nix-serve.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          enableStrictShellChecks = true;
          script = "${pkgs.lib.getExe scripts.nixServeCreateKeys}";
        };
      };

      tmpfiles = {
        settings = {
        };
      };
    };
  };
}
