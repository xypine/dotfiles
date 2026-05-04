{ self, inputs, ... }:
{
  flake.nixosConfigurations.eepc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.eepcConfiguration
    ];
  };
}
