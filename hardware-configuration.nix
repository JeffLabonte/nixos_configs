# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fb70d026-12d3-4a8e-a8ab-46484d057eff";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/39d4536d-c8f3-46af-b171-8f9aed7cca94";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7F50-0614";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0989ac86-8f7a-4b68-b7ed-6890987920ad"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  i18n.consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
