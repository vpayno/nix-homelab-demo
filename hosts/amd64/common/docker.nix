# hosts/amd64/common/docker.nix
{
  config,
  ...
}@args:
{
  config = {
    services = {
      dockerRegistry = {
        enable = true;
      };
    };

    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };
  };
}
