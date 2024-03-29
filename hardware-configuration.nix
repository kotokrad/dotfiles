# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4a6adc8c-fcd9-475d-85b7-1dad9bba0d73";
      fsType = "btrfs";
      options = [ "subvol=nixos" "compress=zstd" "autodefrag" "noatime" ];
    };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/2188ad89-d4c6-4d2e-b251-87db9971eb51";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/4a6adc8c-fcd9-475d-85b7-1dad9bba0d73";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "autodefrag" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B68C-B30F";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/89563890-cca8-4469-9eff-f5a5e7f37b9a"; }
    ];

}
