{ self, inputs, ... }:
let
  helpers = "~/.config/sway/scripts"; # Path for your custom scripts
in
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    {
      services.displayManager.gdm.enable = true;
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };

      # Needed for keyboard shortcuts
      environment.systemPackages = with pkgs; [
        brightnessctl
        playerctl
        wireplumber # This provides the 'wpctl' command
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          prefer-no-csd = { };

          # --- Startup Applications ---
          spawn-at-startup = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=niri"

            (lib.getExe self'.packages.myNoctalia)
            # "${lib.getExe pkgs.noctalia-qs} -c '${lib.getExe self'.packages.myNoctalia}'"
            "wl-paste --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            "${lib.getExe pkgs.swayidle} -w before-sleep '${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock'"
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          layout = {
            always-center-single-column = { };
            focus-ring = {
              off = { };
            };
          };

          # layout = {
          #   gaps = 0; # Mapped from: gaps inner 0 / outer 0
          #
          #   # Disable Niri's default focus ring to match Sway's border style
          #   focus-ring = null;
          #
          #   border = {
          #     enable = true;
          #     width = 2; # Mapped from: border pixel 2
          #
          #     # Gruvbox $focused / $dark
          #     active.color = "#3c3836";
          #
          #     # Gruvbox $unfocused / $inactive
          #     inactive.color = "#282828";
          #   };
          # };

          # Note: Niri doesn't natively support distinct "urgent" border colors
          # in its base layout config, nor does it use "floating borders"
          # since it relies on scrollable tiling rather than floating windows.

          input = {
            warp-mouse-to-focus = { };

            touchpad = {
              tap = { };
              natural-scroll = { };
            };

            keyboard = {
              repeat-delay = 300;
              repeat-rate = 40;
              xkb = {
                layout = "eu,fi";
                variant = ",nodeadkeys";
                options = "caps:swapescape";
              };
            };

          };

          # --- Key Bindings ---
          binds = {
            # Audio / Volume
            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

            # Media Controls
            "XF86AudioPlay".spawn-sh = "playerctl play-pause";
            "XF86AudioPause".spawn-sh = "playerctl pause";
            "XF86AudioNext".spawn-sh = "playerctl next";
            "XF86AudioPrev".spawn-sh = "playerctl previous";

            # Screen Brightness
            "XF86MonBrightnessUp".spawn-sh = "brightnessctl set 5%+";
            "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 5%-";

            # Basics
            "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
            "Mod+Shift+Q".close-window = { };
            "Mod+D".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";

            # Using rofi for cliphist/calc since they are specialized menus.
            # If myNoctalia supports these, you can swap the commands out!
            "Mod+P".spawn-sh =
              "${helpers}/cliphist-rofi-img | rofi -dmenu -p 'Clipboard' -i | cliphist decode | ifne sh -c 'cat | wl-copy'";
            "Mod+N".spawn-sh =
              "rofi -show calc -modi calc -no-show-match -no-sort -automatic-save-to-history -calc-command 'wl-copy {result}'";

            # Utils
            "Mod+Shift+P".spawn-sh =
              "grim -g \\\"$(slurp -p)\\\" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n 1 | cut -d ' ' -f 4 | wl-copy";
            "Mod+Shift+S".spawn-sh = "grim -g \\\"$(slurp -d)\\\" - | wl-copy --type image/png";
            "Mod+Alt+S".spawn-sh =
              "pkill -SIGINT wf-recorder || wf-recorder -y -g \\\"$(slurp)\\\" -f ~/Videos/latest.mkv > ~/Videos/wf-recorder.log 2>&1";
            "Mod+X".spawn-sh = "pkill waybar || waybar";

            # Specialized Terminals
            "Mod+Shift+Return".spawn-sh = "alacritty --working-directory=$(${helpers}/wlcwd)";
            "Mod+B".spawn-sh = "kitty --working-directory=$(${helpers}/wlcwd) -e yazi";

            # Focus (h, j, k, l)
            "Mod+H".focus-column-or-monitor-left = { };
            "Mod+J".focus-window-or-monitor-down = { };
            "Mod+K".focus-window-or-monitor-up = { };
            "Mod+L".focus-column-or-monitor-right = { };

            # Move (Shift + h, j, k, l)
            "Mod+Shift+H".consume-or-expel-window-left = { };
            "Mod+Shift+J".move-window-down-or-to-workspace-down = { };
            "Mod+Shift+K".move-window-up-or-to-workspace-up = { };
            "Mod+Shift+L".consume-or-expel-window-right = { };
            "Mod+Shift+bracketleft".move-column-left-or-to-monitor-left = { };
            "Mod+Shift+bracketright".move-column-right-or-to-monitor-right = { };

            # Workspaces
            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;
            "Mod+0".focus-workspace = 10;

            # Move to Workspaces
            "Mod+Shift+1".move-column-to-workspace = 1;
            "Mod+Shift+2".move-column-to-workspace = 2;
            "Mod+Shift+3".move-column-to-workspace = 3;
            "Mod+Shift+4".move-column-to-workspace = 4;
            "Mod+Shift+5".move-column-to-workspace = 5;
            "Mod+Shift+6".move-column-to-workspace = 6;
            "Mod+Shift+7".move-column-to-workspace = 7;
            "Mod+Shift+8".move-column-to-workspace = 8;
            "Mod+Shift+9".move-column-to-workspace = 9;
            "Mod+Shift+0".move-column-to-workspace = 10;

            # Layout Manipulation (Closest Niri Equivalents)
            "Mod+C".consume-window-into-column = { };
            "Mod+V".expel-window-from-column = { };
            "Mod+F".maximize-column = { };
            "Mod+Shift+F".fullscreen-window = { };
            "Mod+Ctrl+Shift+F".toggle-windowed-fullscreen = { };

            "Mod+Shift+Space".toggle-window-floating = { };

            # Resizing (Replaces Sway's resize mode)
            "Mod+Ctrl+H".set-column-width = "-10%";
            "Mod+Ctrl+L".set-column-width = "+10%";
            "Mod+Ctrl+K".set-window-height = "-10%";
            "Mod+Ctrl+J".set-window-height = "+10%";

            # System
            "Mod+Shift+C".spawn-sh = "niri msg action do-screen-transition"; # Fun visual reload
            "Mod+Shift+E".quit = { };
          };
        };
      };
    };
}
