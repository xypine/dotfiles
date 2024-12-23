{ config, pkgs, inputs, ... }:

{
  networking.hostName = "eepc";

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Media server
  services.jellyfin.enable = true;

  # For steam 
  hardware.graphics.enable32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # Misc packages
  environment.systemPackages = with pkgs; [
    bitwig-studio
  ];

  # Backlight control for external displays
  hardware.i2c.enable = true;
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
  boot.kernelModules = [ "i2c-dev" "ddcci_backlight" ];

  # Factorio server
  # services.factorio = {
  #   enable = true;
  # };
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
      enable-rcon = false;
      # This password can be used to administer your minecraft server.
      # Exact details as to how will be explained later. If you want
      # you can replace this with another password.
      "rcon.password" = "2nicegamebro1";
      level-seed = "10292992";
    };
  };

  # Local LLM backend
  services.ollama = {
    enable = true;
    acceleration = "rocm";
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
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h localhost --player pulse";
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
        "framework" = { id = "LZ4PBSZ-6AQOTSE-LKR4H5X-EURURFD-BGBMWXW-KJMCODJ-Y4WUZDI-YWFIOQE"; autoAcceptFolders = true; };
        "compaq" = { id = "CK6VPIN-ZC6WWSO-HQZXFKH-DRSJCSV-WC750VZ-JKRAHJE-WOO63G2-TSP4AQ7"; autoAcceptFolders = true; };
        "snote" = { id = "QAWFVL3-FPKO7II-HBBAUEZ-SFTRJXW-ONUGZOB-XD37KL3-AA6UEXT-CO2KUQJ"; autoAcceptFolders = true; };
        "yoga" = { id = "2X2MYK6-NIVMB4E-ISRV53P-C2XCKIJ-UZBP6JG-C7GCU3P-4MLKTKP-W3V7TQO"; autoAcceptFolders = true; };
        "op9" = { id = "QHBG3X6-IINRX47-T2XSLHC-G5HZRZV-ZSQQSOS-KQOWOQP-PLJLTAQ-HEBS2QO"; autoAcceptFolders = true; };
        # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      folders = {
        "Sync" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/elias/Sync"; # Which folder to add to Syncthing
          devices = [ "yoga" "op9" ];
          id = "fi.ruta.default-11";
        };
        "SNOTE Document" = {
          path = "/home/elias/SNOTE/Document";
          devices = [ "snote" "op9" "yoga" "framework" ];
          id = "f1pck-thru9";
        };
        "SNOTE Export" = {
          path = "/home/elias/SNOTE/Export";
          devices = [ "snote" "op9" "yoga" "framework" ];
          id = "eeyb3-mgteg";
        };
        "SNOTE Note" = {
          path = "/home/elias/SNOTE/Note";
          devices = [ "snote" "op9" "yoga" "framework" ];
          id = "xl1sw-jjhif";
        };
        "SNOTE WP" = {
          path = "/home/elias/SNOTE/WP";
          devices = [ "snote" "op9" "yoga" "compaq" "framework" ];
          id = "7b60c-guusr";
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
