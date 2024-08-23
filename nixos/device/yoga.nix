{ config, pkgs, inputs, ... }:

{
  networking.hostName = "yoga-slim-7-pro";

  # Map encrypted drive correctly
  boot.initrd.luks.devices."luks-c6ab16ad-0bbe-424f-b9ef-9807889c9ad6".device = "/dev/disk/by-uuid/c6ab16ad-0bbe-424f-b9ef-9807889c9ad6";

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Enable bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Power profiles (performance, balanced, powersave)
  services.power-profiles-daemon.enable = true;

  # Backlight control
  programs.light.enable = true;


  # Snapcast client listening to pc
  systemd.user.services.snapclient-local = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h eepc";
    };
  };

  # Syncthing
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  services.syncthing = {
    enable = true;
    user = "elias";
    dataDir = "/home/elias/";
    configDir = "/home/elias/.config/syncthing";
    key = "/home/elias/.keys/yoga/key.pem";
    cert = "/home/elias/.keys/yoga/cert.pem";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    guiAddress = "0.0.0.0:8384";
    settings = {
      options = {
        gui = { user = "elias"; };
      };
      devices = {
        "eepc" = { id = "EVNII26-II6BDA5-3ROTCHC-YGTAYKC-JA4P6PM-EOQ24AL-4FGOSRV-BBABNAQ"; };
        # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      folders = {
        "Sync" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/elias/Sync"; # Which folder to add to Syncthing
          # devices = [ "eepc" ];
          id = "fi.ruta.default-11";
        };
      };
    };
  };

  # Open ports in the firewall.
  # 5900: VNC
  # Syncthing ports: 8384 for remote access to GUI
  # 22000 TCP and/or UDP for sync traffic
  # 21027/UDP for discovery
  # source: https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [ 5900 22000 ];
  networking.firewall.allowedUDPPorts = [ 5900 22000 21027 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
}
