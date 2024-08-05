{ config, pkgs, ... }:

{
  home.username = "elias";
  home.homeDirectory = "/home/elias";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    fastfetch
    ranger # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # misc
    firefox
    tree
    dotter
    neovim
    darkman
    blender-hip
    clinfo
    qbittorrent
    discord
    croc

    # MPRIS support
    playerctl
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Elias Eskelinen";
    userEmail = "git@eliaseskelinen.fi";
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      window = {
        #opacity = 0.8;
        blur = true;
        decorations = "none";
        padding = {
          x = 0;
          y = 0;
        };
      };
      keyboard = {
        bindings = [
          { key = "F11"; action = "ToggleFullscreen"; }
        ];
      };
      mouse = {
        hide_when_typing = true;
      };
      selection.save_to_clipboard = true;
      cursor.style = {
        shape = "beam";
        blinking = "Off";
      };
      shell = {
        program = "zsh";
        #args = ["-l" "-c" "tmux new-session"];
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    shellAliases = {
      xvim = "nix run ~/coding/nixvim-config";
    };
  };
  # Cooler shell history
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      auto_sync = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = (with builtins; fromTOML (readFile ./starship_preset.toml)) // {
      # Overrides here
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
