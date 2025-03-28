# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    systemd-boot.configurationLimit = 12;
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";
  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.sddm.theme = "xypine";
  # services.displayManager.sddm.settings = {
  #   Theme = {
  #     ThemeDir = "/etc/sddm/themes";
  #   };
  # };
  # services.displayManager.defaultSession = "swayfx";
  # services.displayManager.session = [
  #   {
  #     name = "Sway";
  #     manage = "desktop";
  #     start = "sway";
  #   }
  # ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "eu";
  services.xserver.xkb.options = "caps:escape";
  # Enable support for zsa keyboards, such as the voyager
  hardware.keyboard.zsa.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users = {
    elias = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "video"
        "i2c"
        "disk"
        "adbusers"
      ]; # wheel = Enable ‘sudo’ for the user
      packages = with pkgs; [
        (chromium.override {
          commandLineArgs = [
            "--enable-features=VaapiVideoDecodeLinuxGL"
            "--ignore-gpu-blocklist"
            "--enable-zero-copy"
          ];
        })
        telegram-desktop
      ];
    };
    remoteBuilder = {
      isNormalUser = true;
      createHome = false;
      group = "remotebuild";

      openssh = {
        authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCJ2nux+c7309zPVktQcW0UDUqIPVsX8Tqt2dWmYyR4 nixremote.zero@eliaseskelinen.fi"
        ];
      };
    };
  };
  users.defaultUserShell = pkgs.fish;
  users.groups.remotebuild = { };
  # native wayland for chromium & co
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Necessary permissions for remote builders
  nix.settings.trusted-users = [
    "remoteBuilder"
    "elias"
  ];
  # Allow unfree
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      wlvncc = prev.wlvncc.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "any1";
          repo = "wlvncc";
          rev = "bec7a54fbb835824ac6f8cefbf50181189a5c510";
          hash = "sha256-me4u/Jhr5UBNW07Ug71y5biLdJFqdcgC21uUcC/3bSU=";
        };
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    fastfetch
    mpv
    pavucontrol
    htop
    fd
    tmux
    # C compiler
    zig
    # Patched version of sway with more eye candy
    swayfx-unwrapped
    # Personal nixvim config
    inputs.nixvim.packages."${pkgs.system}".default
    # Homegrown calendar
    inputs.olmonoko.packages."${pkgs.system}".olmonokod
    # rewrite of git-hours
    inputs.git-hou.packages."${pkgs.system}".git-hou
    swayosd
    wlsunset
    nwg-displays

    grim # screenshots
    slurp # screenshots
    wf-recorder # screenrecording
    wl-clipboard
    imagemagick # needed for the colorpicker
    swaylock
    swayidle
    autotiling
    (cliphist.overrideAttrs (_old: {
      src = pkgs.fetchFromGitHub {
        owner = "sentriz";
        repo = "cliphist";
        rev = "c49dcd26168f704324d90d23b9381f39c30572bd";
        sha256 = "sha256-2mn55DeF8Yxq5jwQAjAcvZAwAg+pZ4BkEitP6S2N0HY=";
      };
      vendorHash = "sha256-M5n7/QWQ5POWE4hSCMa0+GOVhEDCOILYqkSYIGoy/l0=";
    }))
    waybar
    swaybg
    wl-kbptr
    lxqt.lxqt-policykit
    foot
    xdg-utils

    brightnessctl

    wayvnc # VNC Server
    wlvncc # VNC Client

    android-udev-rules

    protonup
    gamemode
    mangohud

    docker-compose

    networkmanagerapplet
    adwaita-icon-theme # Needed for some gtk apps

    keymapp # For configuring the ZSA Voyager
  ];
  programs.firefox = {
    enable = true;
    # Nightly firefox
    package = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
  };

  services.snapserver = {
    enable = false;
    codec = "flac";
    streams = {
      pipewire = {
        type = "pipe";
        location = "/run/snapserver/pipewire";
      };
    };
  };
  systemd.user.services.snapcast-sink = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    bindsTo = [
      "pipewire.service"
    ];
    path = with pkgs; [
      gawk
      pulseaudio
    ];
    script = ''
      pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
    '';
  };

  # Enable the fish shell
  programs.fish.enable = true;
  # Enable zsh
  # programs.zsh.enable = true;
  # # Replaced by starship in home.nix
  # # programs.zsh.ohMyZsh = {
  # #   enable = true;
  # #   plugins = [ "git" "sudo" "docker" "kubectl" "rust" "golang" "fd" ];
  # #   theme = "tjkirch";
  # # };

  # Required for swaylock to accept the correct password
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  xdg.portal.config.common.default = "*";

  environment.variables.EDITOR = "nvim";

  xdg.mime.defaultApplications = {
    "application/pdf" = "firefox-nightly.desktop";
    "text/html" = "firefox-nightly.desktop";
    "x-scheme-handler/http" = "firefox-nightly.desktop";
    "x-scheme-handler/https" = "firefox-nightly.desktop";
    "x-scheme-handler/about" = "firefox-nightly.desktop";
    "x-scheme-handler/unknown" = "firefox-nightly.desktop";
  };

  # Install steam
  programs.steam = {
    enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Fonts
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    cantarell-fonts
    montserrat
    lmodern
    nerd-fonts.blex-mono
    nerd-fonts.fira-mono
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # secrets vault
  services.gnome.gnome-keyring.enable = true;

  services.resolved.enable = true;

  # Mesh VPN
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "none";

  # Flatpak
  services.flatpak.enable = true;

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.liveRestore = false; # Slows down shutdown

  # Enable polkit
  security.polkit.enable = true;
  services.udisks2.enable = true;

  stylix.enable = true;
  stylix.image = pkgs.fetchurl {
    name = "ferns.jpg";
    url = "https://i.redd.it/uhzbtokol3p41.jpg";
    sha256 = "a0bb008e0e66addbe5f1e1162ab804fe3f9654d0622f0e40217a59efdffd8854";
  };
  # stylix.image = pkgs.fetchurl {
  #   name = "metro.jpg";
  #   url = "https://wallpapercrafter.com/desktop/17728-night-city-skyscraper-city-lights-metropolis-new-york-united-states-4k.jpg";
  #   sha256 = "sha256-hXaV1RpytljUYh1wRMKx+wmsKruo//emGCjoNUxPWPA=";
  # };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.polarity = "dark";
  stylix.opacity.terminal = 0.925;
  stylix.fonts = {
    sansSerif = {
      package = pkgs.inter;
      name = "Inter";
    };
    monospace = {
      package = pkgs.nerd-fonts.blex-mono;
      name = "BlexMono Nerd Font";
    };
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
  # TODO: Figure out a way to compile this in dark mode
  stylix.cursor = {
    package = pkgs.hackneyed.overrideAttrs (oldAttrs: {
      makeFlags = oldAttrs.makeFlags ++ [ "DARK_THEME=1" ];
    });
    name = "Hackneyed-Dark";
    size = 18;
  };
  stylix.targets.plymouth = {
    enable = false;
  };
  stylix.targets.console.enable = false;

  services.udev.packages = [ pkgs.swayosd ];

  environment.sessionVariables = {
    # only needed for Sway
    XDG_CURRENT_DESKTOP = "sway";
  };

  # Automatically remove old versions and unused packages
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  # nix.buildMachines = [
  #   {
  #     hostName = "eepc";
  #     system = "x86_64-linux";
  #     protocol = "ssh-ng";
  #     maxJobs = 3;
  #     speedFactor = 2;
  #     supportedFeatures = [
  #       "nixos-test"
  #       "benchmark"
  #       "big-parallel"
  #       "kvm"
  #     ];
  #   }
  # ];
  # devenv cachix
  nix.extraOptions = ''
    trusted-users = root elias
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    secret-key-files = /home/elias/Sync/rbuilder/cache-priv-key.pem
  '';

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
