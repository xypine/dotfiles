{ self, inputs, ... }:
let
  helpers = "~/.config/sway/scripts"; # Path for your custom scripts
in
{
  flake.nixosModules.gamescope =
    { pkgs, lib, ... }:
    {
      programs = {
        gamescope = {
          enable = true;
          capSysNice = true;
        };
        steam.gamescopeSession.enable = true;
      };
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
