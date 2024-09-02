{ config, pkgs, inputs, ... }:

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
  stylix.enable = false;

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
