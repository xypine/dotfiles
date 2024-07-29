{ config, pkgs, inputs, ... }:

{
  networking.hostName = "yoga-slim-7-pro";

  # Map encrypted drive correctly
  boot.initrd.luks.devices."luks-c6ab16ad-0bbe-424f-b9ef-9807889c9ad6".device = "/dev/disk/by-uuid/c6ab16ad-0bbe-424f-b9ef-9807889c9ad6";

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
}
