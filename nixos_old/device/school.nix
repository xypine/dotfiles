{ config, pkgs, inputs, ... }:

{
  networking.hostName = "school-laptop";

  # Map encrypted drive correctly
  boot.initrd.luks.devices."luks-18c91370-6c45-4a8c-98e0-2a97f0756258".device = "/dev/disk/by-uuid/18c91370-6c45-4a8c-98e0-2a97f0756258";

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
