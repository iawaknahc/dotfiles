{
  lib,
  ...
}:
let
  border_width = 2;
  spacing = 8;
  # When 2 windows are placed adjacent, the visual spacing should be
  # border width of window A + spacing + border width of window B.
  window_spacing = spacing + border_width * 2;
in
{
  services.jankyborders.enable = true;
  services.jankyborders.settings = {
    style = "round";
    # Apparently, this width is the sum of all 4 borders.
    width = border_width * 4.0;
  };

  programs.aerospace.enable = true;
  programs.aerospace.launchd.enable = true;
  programs.aerospace.settings = {
    config-version = 2;

    persistent-workspaces = [
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
    ];

    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";

    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

    key-mapping.preset = "qwerty";

    # Make all windows tiled by default.
    on-window-detected = [
      {
        "if" = "test %{app-bundle-id} = org.gnu.Emacs && test %{window-title} = mylauncher";
        run = [ "layout floating" ];
        check-further-callbacks = true;
      }
    ];

    gaps = {
      inner = {
        horizontal = window_spacing;
        vertical = window_spacing;
      };
      outer = {
        top = window_spacing;
        right = window_spacing;
        bottom = window_spacing;
        left = window_spacing;
      };
    };

    mode.main.binding = {
      alt-h = "focus left";
      alt-j = "focus down";
      alt-k = "focus up";
      alt-l = "focus right";

      alt-n = "focus --boundaries workspace --boundaries-action wrap-around-the-workspace dfs-next";
      alt-p = "focus --boundaries workspace --boundaries-action wrap-around-the-workspace dfs-prev";

      alt-shift-h = "move left";
      alt-shift-j = "move down";
      alt-shift-k = "move up";
      alt-shift-l = "move right";

      # This used to be alt-enter, but alt-enter sometimes conflict with Alfred Workflows.
      alt-f = "fullscreen";

      alt-shift-f = "layout floating tiling";

      alt-m = lib.strings.trim ''
        exec-and-forget osascript -e 'tell application "System Events" to tell process "AeroSpace" to click menu bar item 1 of menu bar 2'
      '';

      alt-minus = "resize smart -50";
      alt-equal = "resize smart +50";
      alt-0 = "balance-sizes";

      alt-1 = "workspace 1";
      alt-2 = "workspace 2";
      alt-3 = "workspace 3";
      alt-4 = "workspace 4";
      alt-5 = "workspace 5";
      alt-6 = "workspace 6";
      alt-7 = "workspace 7";
      alt-8 = "workspace 8";
      alt-9 = "workspace 9";

      alt-shift-1 = [
        "move-node-to-workspace 1"
        "workspace 1"
      ];
      alt-shift-2 = [
        "move-node-to-workspace 2"
        "workspace 2"
      ];
      alt-shift-3 = [
        "move-node-to-workspace 3"
        "workspace 3"
      ];
      alt-shift-4 = [
        "move-node-to-workspace 4"
        "workspace 4"
      ];
      alt-shift-5 = [
        "move-node-to-workspace 5"
        "workspace 5"
      ];
      alt-shift-6 = [
        "move-node-to-workspace 6"
        "workspace 6"
      ];
      alt-shift-7 = [
        "move-node-to-workspace 7"
        "workspace 7"
      ];
      alt-shift-8 = [
        "move-node-to-workspace 8"
        "workspace 8"
      ];
      alt-shift-9 = [
        "move-node-to-workspace 9"
        "workspace 9"
      ];

      alt-tab = "move-workspace-to-monitor --wrap-around next";
    };

    workspace-to-monitor-force-assignment = {
      "1" = "main";
      "2" = "main";
      "3" = "main";
      "4" = "main";
      "5" = "main";
      "6" = "main";
      "7" = "main";
      "8" = "main";
      "9" = "secondary";
    };
  };
}
