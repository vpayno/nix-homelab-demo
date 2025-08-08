# hosts/amd64/common/users.nix
{
  config,
  pkgs,
  ...
}@args:
{
  config = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      users = {
        root = {
          #  {option}`initialHashedPassword` -> {option}`initialPassword` -> {option}`hashedPassword` -> {option}`password` -> {option}`hashedPasswordFile`
          initialPassword = "secret123";
          openssh = {
            authorizedKeys = {
              keys = [
              ];
            };
          };
          password = pkgs.lib.mkIf (builtins.elem config.networking.hostName [
            "nixos"
            "bootstrap"
          ]) "secret234";
        };
        vpayno = {
          isNormalUser = true;
          description = "Victor Payno";
          extraGroups = [
            "audio"
            "docker"
            "kvm"
            "networkmanager"
            "video"
            "wheel"
          ];
          packages = with pkgs; [
            devbox
          ];
          openssh = {
            authorizedKeys = {
              keys = [
              ];
            };
          };
        };
      };
    };
  };
}
