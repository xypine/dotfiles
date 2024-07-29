{ config, pkgs, inputs, ... }:

{
  # Media server
  services.jellyfin.enable = true;
  # Factorio server
  services.factorio = {
    enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
