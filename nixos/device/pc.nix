{ config, pkgs, inputs, ... }:

{
  networking.hostName = "eepc";
  # Media server
  services.jellyfin.enable = true;
  # Factorio server
  services.factorio = {
    enable = true;
  };
  # Minecraft
  services.minecraft-server = {
    enable = true;
    eula = true; # set to true if you agree to Mojang's EULA: https://account.mojang.com/documents/minecraft_eula
    declarative = true;

    # see here for more info: https://minecraft.gamepedia.com/Server.properties#server.properties
    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      motd = "arabiassa arabi \\u00A74\\u00A7karaboi";
      max-players = 20;
      enable-rcon = true;
      # This password can be used to administer your minecraft server.
      # Exact details as to how will be explained later. If you want
      # you can replace this with another password.
      "rcon.password" = "2nicegamebro1";
      level-seed = "10292992";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
