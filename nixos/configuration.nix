# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
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
    nh
    git
    vim
    wget
    curl
    fastfetch
    htop
    fd
    tmux
    # C compiler
    zig
    # Personal nixvim config
    inputs.nixvim.packages."${pkgs.system}".default
    # Homegrown calendar
    inputs.olmonoko.packages."${pkgs.system}".olmonokod
    # rewrite of git-hours
    inputs.git-hou.packages."${pkgs.system}".git-hou
    imagemagick
    android-udev-rules
    docker-compose
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

  environment.variables = {
    EDITOR = "nvim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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

  # Automatically remove old versions and unused packages
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

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
