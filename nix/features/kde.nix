{ self, inputs, ... }:
let
  helpers = "~/.config/sway/scripts"; # Path for your custom scripts
in
{
  flake.nixosModules.kde =
    { pkgs, lib, ... }:
    {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.plasma-login-manager = {
        enable = true;
      };
      services.kdeconnect.enable = true;

      environment.systemPackages = with pkgs; [
        kdePackages.qtwebsockets
      ];

    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      # We could wrap kde packages here
    };
}
