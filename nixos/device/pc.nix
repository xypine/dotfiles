{
  config,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "eepc";
  imports = [
    ../modules/graphical.nix
  ];

  boot = {
    initrd.systemd.enable = true;

    # Fancy boot animation
    plymouth = {
      enable = true;
      # theme = "rings";
      # themePackages = with pkgs; [
      #   # By default we would install all themes
      #   (adi1090x-plymouth-themes.override {
      #     selected_themes = [ "rings" ];
      #   })
      # ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    extraModulePackages = with config.boot.kernelPackages; [
      # Virtual camera
      v4l2loopback
      # Backlight control for external displays
      ddcci-driver
    ];
    kernelModules = [
      "v4l2loopback"
      #
      "i2c-dev"
      "ddcci_backlight"
    ];
  };

  # allow hibernation or hybrid sleep
  services.logind.extraConfig = ''
    SleepOperation="suspend-then-hibernate hybrid-sleep suspend hibernate"
  '';
  services.logind.powerKey = "sleep";
  services.logind.powerKeyLongPress = "poweroff";
  services.logind.hibernateKey = "sleep";

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Media server
  services.jellyfin.enable = true;

  # For steam
  hardware.graphics.enable32Bit = true;
  services.pulseaudio.support32Bit = true;

  # Misc packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    bitwig-studio
    prismlauncher
    openrgb-with-all-plugins
    r2modman
    (pkgs.llama-cpp.override {
      rocmSupport = true;
    })
  ];

  # Backlight control for external displays
  hardware.i2c.enable = true;

  # Automatic login after boot
  services.getty = {
    autologinUser = "elias";
    autologinOnce = true; # Only immediately after boot
  };

  # Factorio server
  # services.factorio = {
  #   enable = true;
  # };
  # Minecraft
  # services.minecraft-server = {
  #   enable = true;
  #   eula = true; # set to true if you agree to Mojang's EULA: https://account.mojang.com/documents/minecraft_eula
  #   declarative = true;
  #
  #   # see here for more info: https://minecraft.gamepedia.com/Server.properties#server.properties
  #   serverProperties = {
  #     server-port = 25565;
  #     gamemode = "survival";
  #     motd = " # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #";
  #     max-players = 20;
  #     enable-rcon = false;
  #     # This password can be used to administer your minecraft server.
  #     # Exact details as to how will be explained later. If you want
  #     # you can replace this with another password.
  #     "rcon.password" = "2nicegamebro1";
  #     level-seed = "10292992";
  #   };
  # };

  # Local LLM backend
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    home = "/mnt/fast/ollama";
    environmentVariables = {
      "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";
    };
  };

  # # Snapcast client listening to pc
  # systemd.user.services.snapclient-local = {
  #   wantedBy = [
  #     "default.target"
  #   ];
  #   after = [
  #     "pipewire.service"
  #     "pipewire-pulse.service"
  #   ];
  #   serviceConfig = {
  #     ExecStartPre = "${pkgs.coreutils}/bin/sleep 5"; # Add a 5-second delay before starting snapclient
  #     ExecStart = "${pkgs.snapcast}/bin/snapclient -h 127.0.0.1 --player pulse -s alsa_output.pci-0000_00_1f.3.analog-stereo";
  #   };
  # };
  # Snapcast client listening to homeassistant
  systemd.user.services.snapclient-ha = {
    wantedBy = [
      "default.target"
    ];
    after = [
      "pipewire.service"
      "pipewire-pulse.service"
    ];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10"; # Add a 5-second delay before starting snapclient
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h homeassistant --player pulse -s alsa_output.pci-0000_00_1f.3.analog-stereo";
      Restart = "always";

    };
  };

  # OpenRGB
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
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
  services.rkvm = {
    enable = true;
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
    guiAddress = "0.0.0.0:8384";
    settings = {
      options = {
        gui = {
          user = "elias";
        };
      };
      devices = {
        "framework" = {
          id = "LZ4PBSZ-6AQOTSE-LKR4H5X-EURURFD-BGBMWXW-KJMCODJ-Y4WUZDI-YWFIOQE";
          autoAcceptFolders = true;
        };
        "compaq" = {
          id = "CK6VPIN-ZC6WWSO-HQZXFKH-DRSJCSV-WC750VZ-JKRAHJE-WOO63G2-TSP4AQ7";
          autoAcceptFolders = true;
        };
        "snote" = {
          id = "QAWFVL3-FPKO7II-HBBAUEZ-SFTRJXW-ONUGZOB-XD37KL3-AA6UEXT-CO2KUQJ";
          autoAcceptFolders = true;
        };
        "yoga" = {
          id = "2X2MYK6-NIVMB4E-ISRV53P-C2XCKIJ-UZBP6JG-C7GCU3P-4MLKTKP-W3V7TQO";
          autoAcceptFolders = true;
        };
        "op9" = {
          id = "QHBG3X6-IINRX47-T2XSLHC-G5HZRZV-ZSQQSOS-KQOWOQP-PLJLTAQ-HEBS2QO";
          autoAcceptFolders = true;
        };
        # "device1" = { id = "DEVICE-ID-GOES-HERE"; };
        # "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      folders = {
        "Sync" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/elias/Sync"; # Which folder to add to Syncthing
          devices = [
            "yoga"
            "op9"
          ];
          id = "fi.ruta.default-11";
        };
        "SNOTE Document" = {
          path = "/home/elias/SNOTE/Document";
          devices = [
            "snote"
            "op9"
            "yoga"
            "framework"
          ];
          id = "f1pck-thru9";
        };
        "SNOTE Export" = {
          path = "/home/elias/SNOTE/Export";
          devices = [
            "snote"
            "op9"
            "yoga"
            "framework"
          ];
          id = "eeyb3-mgteg";
        };
        "SNOTE Note" = {
          path = "/home/elias/SNOTE/Note";
          devices = [
            "snote"
            "op9"
            "yoga"
            "framework"
          ];
          id = "xl1sw-jjhif";
        };
        "SNOTE WP" = {
          path = "/home/elias/SNOTE/WP";
          devices = [
            "snote"
            "op9"
            "yoga"
            "compaq"
            "framework"
          ];
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
