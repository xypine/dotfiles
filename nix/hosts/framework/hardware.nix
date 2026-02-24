{ self, inputs, ... }:
{

  flake.nixosModules.frameworkHardware =
    {
      pkgs,
      lib,
      config,
      modulesPath,
      ...
    }:
    {

      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/4051d16f-c237-452b-bad9-c0cc6564f08f";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-d2179ea7-38eb-490a-a3ca-2a025f3285d8".device =
        "/dev/disk/by-uuid/d2179ea7-38eb-490a-a3ca-2a025f3285d8";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/4D4B-31F0";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/77a22b77-085b-4527-a807-8f7587807681"; }
      ];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}
