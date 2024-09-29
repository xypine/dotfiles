{ config, pkgs, lib, inputs, ... }:

{
  networking.hostName = "compaq";

  # The device has a ridiculously low amount of ram!
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # 8GB
    }
  ];

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Not needed, host mainly used for server use
  stylix.enable = lib.mkForce false;

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
    key = "/home/elias/.keys/compaq/key.pem";
    cert = "/home/elias/.keys/compaq/cert.pem";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    guiAddress = "0.0.0.0:8384";
    settings = {
      options = {
        gui = { user = "elias"; };
      };
      devices = {
        "snote" = { id = "QAWFVL3-FPKO7II-HBBAUEZ-SFTRJXW-ONUGZOB-XD37KL3-AA6UEXT-CO2KUQJ"; autoAcceptFolders = true; };
        "eepc" = { id = "EVNII26-II6BDA5-3ROTCHC-YGTAYKC-JA4P6PM-EOQ24AL-4FGOSRV-BBABNAQ"; autoAcceptFolders = true; };
        "yoga" = { id = "2X2MYK6-NIVMB4E-ISRV53P-C2XCKIJ-UZBP6JG-C7GCU3P-4MLKTKP-W3V7TQO"; autoAcceptFolders = true; };
        "op9" = { id = "QHBG3X6-IINRX47-T2XSLHC-G5HZRZV-ZSQQSOS-KQOWOQP-PLJLTAQ-HEBS2QO"; autoAcceptFolders = true; };
        # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      folders = {
        "SNOTE WP" = {
          path = "/home/elias/SNOTE_WP";
          devices = [ "snote" "op9" "yoga" "eepc" ];
          id = "7b60c-guusr";
        };
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
