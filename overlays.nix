# overlays.nix
{
  ...
}:
let
  overlayLinuxFirmware = (
    self: super: {
      linux-firmware-20250509 = super.linux-firmware.overrideAttrs (oldAttrs: {
        pname = "linux-firmware";
        version = "20250509";
        name = "${self.linux-firmware-20250509.pname}-${self.linux-firmware-20250509.version}";
        src = super.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "a8a4418105eb0ecf4baeb6ac54ce8d56855f3124";
          hash = "sha256-0FrhgJQyCeRCa3s0vu8UOoN0ZgVCahTQsSH0o6G6hhY=";
        };
      });

      linux-firmware-20250613 = super.linux-firmware.overrideAttrs (oldAttrs: {
        pname = "linux-firmware";
        version = "20250613";
        name = "${self.linux-firmware-20250613.pname}-${self.linux-firmware-20250613.version}";
        src = super.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "12fe085fa4096dedd82a9af0901fb8721379011f";
          hash = "sha256-qygwQNl99oeHiCksaPqxxeH+H7hqRjbqN++Hf9X+gzs=";
        };
      });

      linux-firmware-20250621 = super.linux-firmware.overrideAttrs (oldAttrs: {
        pname = "linux-firmware";
        version = "20250621";
        name = "${self.linux-firmware-20250621.pname}-${self.linux-firmware-20250621.version}";
        src = super.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "49c833a10ad96a61a218d28028aed20aeeac124c";
          hash = "sha256-Pz/k/ol0NRIHv/AdridwoBPDLsd0rfDAj31Paq4mPpU=";
        };
      });

      linux-firmware-20250627 = super.linux-firmware.overrideAttrs (oldAttrs: {
        pname = "linux-firmware";
        version = "20250627";
        name = "${self.linux-firmware-20250627.pname}-${self.linux-firmware-20250627.version}";
        src = super.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "f40eafe216833d083f4e5598b7f45e894c373ad1";
          hash = "sha256-mNjCl+HtvvFxyLjlBFsyfyu2TAf6D/9lbRiouKC/vVY=";
        };
      });

      linux-firmware-20250725 = super.linux-firmware.overrideAttrs (oldAttrs: {
        pname = "linux-firmware";
        version = "20250725";
        name = "${self.linux-firmware-20250725.pname}-${self.linux-firmware-20250725.version}";
        src = super.fetchgit {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
          rev = "4bb152fb440528d7abb8a18c3879ea5b4be416c2";
          hash = "sha256-dQRAxn+nohM32qz89MUm+UBp5Y8mkRqqxicm5G37cpY=";
        };
      });

      linux-firmware-20250708 = super.linux-firmware;

      #linux-firmware = self.linux-firmware-20250725; # version 20250627 released
    }
  );
in
{
  nixpkgs.overlays = [
    overlayLinuxFirmware
  ];
}
