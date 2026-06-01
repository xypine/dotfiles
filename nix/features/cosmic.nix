{ self, inputs, ... }:
let
  helpers = "~/.config/sway/scripts"; # Path for your custom scripts
in
{
  flake.nixosModules.cosmic =
    { pkgs, lib, ... }:
    {
      # Enable the COSMIC login manager
      services.displayManager.cosmic-greeter.enable = true;

      # Enable the COSMIC desktop environment
      services.desktopManager.cosmic.enable = true;
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
