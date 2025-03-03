{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

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

  # Tray icon for mounting usb sticks / sd cards
  services.udiskie = {
    enable = true;
    automount = false;
  };
  services.easyeffects.enable = true;
  services.swaync.enable = true;
  systemd.user.targets.tray = {
    # see https://github.com/nix-community/home-manager/issues/2064
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    fastfetch
    chafa
    ueberzugpp

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
    moreutils # Required for clipboard manager to work (contains ifne)
    libqalculate # Fancy calculator
    direnv # Automatic per-directory environments
    devenv # Ergonomic dev-environments

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
    tree
    dotter
    darkman
    #blender-hip
    clinfo
    qbittorrent
    discord
    croc
    obsidian
    gimp
    inkscape
    vesktop # discord with fixes
    tidal-hifi # tidal desktop client
    resources
    slack

    # MPRIS support
    playerctl
    # EQ
    easyeffects
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Elias Eskelinen";
    userEmail = "git@eliaseskelinen.fi";
    signing = {
      signByDefault = true;
      format = "ssh";
      key = "~/.ssh/id_rsa.pub";
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      window = {
        blur = true;
        decorations = "none";
        padding = {
          x = 0;
          y = 0;
        };
      };
      keyboard = {
        bindings = [
          {
            key = "F11";
            action = "ToggleFullscreen";
          }
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
      terminal.shell = {
        program = "fish";
        #args = ["-l" "-c" "tmux new-session"];
      };
    };
  };
  programs.kitty = {
    enable = true;
  };

  programs.imv.enable = true;
  # terminal file manager
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      manager = {
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };
      preview = {

      };
    };
    theme = (with builtins; fromTOML (readFile ./yazi_gruvbox.toml)) // {
      # Overrides here
    };
  };

  gtk = {
    iconTheme = {
      package = pkgs.tela-circle-icon-theme.override {
        colorVariants = [
          "green"
          "black"
        ];
      };
      name = "Tela-circle-black";
    };
  };

  programs.fish = {
    enable = true;
    functions = {
      # Disable default greeting
      fish_greeting = "";
    };
    shellAliases = {
      xvim = "nix run ~/coding/nixvim-config";
      nrun = "nix-shell --run $SHELL -p";
    };
    loginShellInit = ''
      if test (id --user $USER) -ge 1000 && test (tty) = "/dev/tty1"
        exec sway
      end
    '';
  };
  # Cooler shell history
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow" # Clashes with fish autosuggestions
    ];
    settings = {
      auto_sync = true;
      style = "compact";
      inline_height = 0;
      dialect = "uk";
      workspaces = true;
      exit_mode = "return-query";
      keymap_mode = "vim-insert";
      search_mode = "skim";
    };
  };

  # Nice, performant shell prompt
  programs.starship = {
    enable = true;
    settings = (with builtins; fromTOML (readFile ./starship_preset.toml)) // {
      # Overrides here
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = [
      pkgs.rofi-calc
      pkgs.rofi-emoji-wayland
    ];

    # we have a handwritten config we don't want to replace
    configPath = ".config/rofi-homemanager/config.rasi";
  };

  # Stylix hyprland integration is enabled by default and breaks things
  stylix.targets.hyprland.enable = false;
  stylix.targets.fish.enable = false;
  stylix.targets.swaync.enable = false;
  stylix.targets.yazi.enable = false;

  programs.tmux.enable = true;

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
