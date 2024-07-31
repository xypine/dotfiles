# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # plymouth = {
    #   enable = true;
    #   # theme = "red_loader";
    #   # themePackages = with pkgs; [
    #   #   # By default we would install all themes
    #   #   (adi1090x-plymouth-themes.override {
    #   #     selected_themes = [ "red_loader" ];
    #   #   })
    #   # ];
    # };

    # # Enable "Silent Boot"
    # consoleLogLevel = 0;
    # initrd.verbose = false;
    # kernelParams = [
    #   "quiet"
    #   "splash"
    #   "boot.shell_on_fail"
    #   "loglevel=3"
    #   "rd.systemd.show_status=false"
    #   "rd.udev.log_level=3"
    #   "udev.log_priority=3"
    # ];
    # # Hide the OS choice for bootloaders.
    # # It's still possible to open the bootloader list by pressing any key
    # # It will just not appear on screen unless a key is pressed
    # loader.timeout = 0;
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users.elias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ]; # wheel = Enable ‘sudo’ for the user
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
  users.defaultUserShell = pkgs.zsh;
  # native wayland for chromium & co
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow unfree
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sddm
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
    # Install swayfx from a custom repo
    inputs.swayfx.packages."${pkgs.system}".swayfx-unwrapped

    grim # screenshots
    slurp # screenshots
    wl-clipboard
    swaylock
    swayidle
    autotiling
    cliphist
    waybar
    rofi-wayland
    dunst
    swaybg
    lxqt.lxqt-policykit
    foot

    brightnessctl

    wayvnc # VNC Server
    wlvncc # VNC Client

    protonup
    gamemode
    mangohud

    docker-compose

    networkmanagerapplet
  ];

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

  # Enable zsh
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "docker" "kubectl" "rust" "golang" "fd" ];
    theme = "tjkirch";
  };

  # Required for swaylock to accept the correct password
  security.pam.services.swaylock = { };

  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; };
  xdg.portal.config.common.default = "*";

  environment.variables.EDITOR = "vim";

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
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "IBMPlexMono" "FiraCode" ]; })
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # secrets vault
  services.gnome.gnome-keyring.enable = true;

  # Mesh VPN
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  # Flatpak
  services.flatpak.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # Enable polkit
  security.polkit.enable = true;


  stylix.enable = true;
  stylix.image = pkgs.fetchurl {
    url = "https://i.redd.it/uhzbtokol3p41.jpg";
    sha256 = "a0bb008e0e66addbe5f1e1162ab804fe3f9654d0622f0e40217a59efdffd8854";
  };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.fonts = {
    sansSerif = {
      package = pkgs.inter;
      name = "Inter";
    };
    monospace = {
      package = pkgs.nerdfonts.override { fonts = [ "IBMPlexMono" ]; };
      name = "BlexMono Nerd Font";
    };
  };
  # TODO: Figure out a way to compile this in dark mode
  stylix.cursor = {
    package = pkgs.hackneyed;
    name = "Hackneyed";
    size = 24;
  };

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

