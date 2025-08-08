# hosts/amd64/common/security.nix
{
  config,
  ...
}@args:
let
  enableTPM = true;
in
{
  config = {
    boot = {
      initrd = {
        systemd = {
          tpm2 = {
            enable = enableTPM;
          };
        };
      };
    };

    security = {
      enableWrappers = true;
      sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };
      tpm2 = {
        enable = enableTPM;
        abrmd.enable = false;
      };
    };

    systemd = {
      tpm2 = {
        enable = enableTPM;
      };
    };
  };
}
