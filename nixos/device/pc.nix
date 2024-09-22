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
      motd = " # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #";
      max-players = 20;
      enable-rcon = true;
      # This password can be used to administer your minecraft server.
      # Exact details as to how will be explained later. If you want
      # you can replace this with another password.
      "rcon.password" = "2nicegamebro1";
      level-seed = "10292992";
    };
  };
  # Snapcast client listening to pc
  systemd.user.services.snapclient-local = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h localhost --player pulse -s 214";
    };
  };
  # TUI Git server
  services.soft-serve = {
    enable = true;
    settings = {
      name = "EEPC";
      ssh = {
        listen_addr = ":23231";
        public_url = "ssh://eepc:23231";
      };
      http = {
        listen_addr = ":23232";
        public_url = "http://eepc:23232";
      };
      stats.listen_addr = ":23233";
      initial_admin_keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPPdANVtEU5YNoQepD3c1ymriPUeOXgkZUMgcNYYMUR git@eliaseskelinen.fi"
      ];
    };
  };
  # Syncthing
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  services.syncthing = {
    enable = true;
    user = "elias";
    dataDir = "/home/elias/";
    configDir = "/home/elias/.config/syncthing";
    key = "/home/elias/.keys/eepc/key.pem";
    cert = "/home/elias/.keys/eepc/cert.pem";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    guiAddress = "0.0.0.0:8384";
    settings = {
      options = {
        gui = { user = "elias"; };
      };
      devices = {
        "yoga" = { id = "2X2MYK6-NIVMB4E-ISRV53P-C2XCKIJ-UZBP6JG-C7GCU3P-4MLKTKP-W3V7TQO"; autoAcceptFolders = true; };
        # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      folders = {
        "Sync" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/elias/Sync"; # Which folder to add to Syncthing
          devices = [ "yoga" ];
          id = "fi.ruta.default-11";
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
