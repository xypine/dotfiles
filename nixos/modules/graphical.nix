{
  pkgs,
  inputs,
  ...
}:

{
  # Keyboard & input
  ##################
  services.xserver = {
    xkb.layout = "eu";
    xkb.options = "caps:escape";
  };
  # Enable support for zsa keyboards, such as the voyager
  hardware.keyboard.zsa.enable = true;

  # Wayland & XDG portals
  #######################
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # native wayland for chromium & co
    XDG_CURRENT_DESKTOP = "sway";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Display manager / session
  ###########################
  # services.displayManager.sddm = {
  #   enable  = true;
  #   wayland.enable = true;
  #   theme   = "xypine";
  # };
  #
  # services.displayManager.defaultSession = "swayfx";

  # Required for swaylock to accept the correct password
  security.pam.services.swaylock = { };

  # Stylix
  ########
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://i.redd.it/uhzbtokol3p41.jpg";
      sha256 = "a0bb008e0e66addbe5f1e1162ab804fe3f9654d0622f0e40217a59efdffd8854";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";
    opacity.terminal = 0.925;

    fonts = {
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

    cursor = {
      package = pkgs.hackneyed.overrideAttrs (old: {
        makeFlags = old.makeFlags ++ [ "DARK_THEME=1" ];
      });
      name = "Hackneyed-Dark";
      size = 18;
    };

    targets = {
      plymouth.enable = false;
      console.enable = false;
    };
  };

  # Fonts
  #######
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      cantarell-fonts
      montserrat
      lmodern
      nerd-fonts.blex-mono
      nerd-fonts.fira-mono
    ];
  };

  # Graphical applications / desktop tools
  ########################################
  environment.systemPackages = with pkgs; [
    mpv
    pavucontrol
    # Patched version of sway with more eye candy
    swayfx-unwrapped
    swayosd
    wlsunset
    nwg-displays
    grim # screenshots
    slurp # screenshots
    wf-recorder # screenrecording
    wl-clipboard
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
    xdg-utils
    brightnessctl
    wayvnc # VNC Server
    wlvncc # VNC Client
    networkmanagerapplet
    adwaita-icon-theme # Needed for some gtk apps
    protonup
    gamemode
    mangohud
    keymapp # For configuring the ZSA Voyager
    telegram-desktop
    (chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
  ];

  # GUI programs
  ##############
  programs.firefox = {
    enable = true;
    package = inputs.firefox.packages."${pkgs.system}".firefox-nightly-bin;
  };
  xdg.mime.defaultApplications = {
    "application/pdf" = "firefox-nightly.desktop";
    "text/html" = "firefox-nightly.desktop";
    "x-scheme-handler/http" = "firefox-nightly.desktop";
    "x-scheme-handler/https" = "firefox-nightly.desktop";
    "x-scheme-handler/about" = "firefox-nightly.desktop";
    "x-scheme-handler/unknown" = "firefox-nightly.desktop";
  };

  programs.steam.enable = true; # gaming

  # udev rules
  ############
  services.udev.packages = [ pkgs.swayosd ];

  # services
  ##########
  services.udisks2.enable = true;
}
