{
  config,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "framework";
  imports = [
    ../modules/graphical.nix
  ];

  boot = {
    initrd.systemd.enable = true;

    # Map encrypted drive correctly
    initrd.luks.devices."luks-2112056d-9ba3-4e2f-8df3-3921cffbe90b".device =
      "/dev/disk/by-uuid/2112056d-9ba3-4e2f-8df3-3921cffbe90b";

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

    # Enable virtual camera
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernelModules = [
      "v4l2loopback"
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };

  # Automatic login after boot
  services.getty = {
    autologinUser = "elias";
    autologinOnce = true; # Only immediately after boot
  };

  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;

  # Enable networking
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Enable bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Power profiles (performance, balanced, powersave)
  services.power-profiles-daemon.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Fingerprint sensor support
  services.fprintd.enable = true;

  # Firmware upgrades
  services.fwupd.enable = true;

  # Smarter fan control
  hardware.fw-fanctrl = {
    enable = true;
    config = {
      strategies = {
        "school" = {
          fanSpeedUpdateFrequency = 2;
          movingAverageInterval = 40;
          speedCurve = [
            {
              temp = 30;
              speed = 10;
            }
            {
              temp = 40;
              speed = 20;
            }
            {
              temp = 65;
              speed = 25;
            }
            {
              temp = 70;
              speed = 30;
            }
            {
              temp = 80;
              speed = 50;
            }
            {
              temp = 85;
              speed = 70;
            }
          ];
        };
      };
    };
    disableBatteryTempCheck = false;
  };

  # Misc packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    bitwig-studio
    prismlauncher
    lutris
    libreoffice
  ];

  # allow hibernation or hybrid sleep
  services.logind.settings.Login = {
    SleepOperation = "suspend-then-hibernate hybrid-sleep suspend hibernate";
    HandlePowerKey = "sleep";
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
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h eepc";
      Restart = "always";
    };
  };

  # Snapcast client listening to homeassistant
  systemd.user.services.snapclient-ha = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h homeassistant";
      Restart = "always";
    };
  };

  # Syncthing
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  services.syncthing = {
    enable = true;
    user = "elias";
    dataDir = "/home/elias/";
    configDir = "/home/elias/.config/syncthing";
    key = "/home/elias/.keys/framework/key.pem";
    cert = "/home/elias/.keys/framework/cert.pem";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    guiAddress = "0.0.0.0:8384";
    settings = {
      options = {
        gui = {
          user = "elias";
        };
      };
      devices = {
        "compaq" = {
          id = "CK6VPIN-ZC6WWSO-HQZXFKH-DRSJCSV-WC750VZ-JKRAHJE-WOO63G2-TSP4AQ7";
          autoAcceptFolders = true;
        };
        "snote" = {
          id = "QAWFVL3-FPKO7II-HBBAUEZ-SFTRJXW-ONUGZOB-XD37KL3-AA6UEXT-CO2KUQJ";
          autoAcceptFolders = true;
        };
        "eepc" = {
          id = "EVNII26-II6BDA5-3ROTCHC-YGTAYKC-JA4P6PM-EOQ24AL-4FGOSRV-BBABNAQ";
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
            "eepc"
            "op9"
          ];
          id = "fi.ruta.default-11";
        };
        "SNOTE Document" = {
          path = "/home/elias/SNOTE/Document";
          devices = [
            "snote"
            "op9"
            "eepc"
          ];
          id = "f1pck-thru9";
        };
        "SNOTE Export" = {
          path = "/home/elias/SNOTE/Export";
          devices = [
            "snote"
            "op9"
            "eepc"
          ];
          id = "eeyb3-mgteg";
        };
        "SNOTE Note" = {
          path = "/home/elias/SNOTE/Note";
          devices = [
            "snote"
            "op9"
            "eepc"
          ];
          id = "xl1sw-jjhif";
        };
        "SNOTE WP" = {
          path = "/home/elias/SNOTE/WP";
          devices = [
            "snote"
            "op9"
            "compaq"
            "eepc"
          ];
          id = "7b60c-guusr";
        };
      };
    };
  };

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "eepc";
      sshUser = "remoteBuilder";
      sshKey = "/home/elias/.ssh/nixremote-zero";
      system = pkgs.stdenv.hostPlatform.system;
      protocol = "ssh-ng";
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 20;
      speedFactor = 2;
    }
  ];

  # Open ports in the firewall.
  # 5900: VNC
  # Syncthing ports: 8384 for remote access to GUI
  # 22000 TCP and/or UDP for sync traffic
  # 21027/UDP for discovery
  # source: https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [
    5900
    22000
  ];
  networking.firewall.allowedUDPPorts = [
    5900
    22000
    21027
  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
}
