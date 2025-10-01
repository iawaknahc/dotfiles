{
  ...
}:
{
  programs.aerospace.enable = true;
  programs.aerospace.userSettings = {
    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";

    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

    key-mapping.preset = "qwerty";

    on-window-detected = [
      {
        run = [
          "layout floating"
        ];
      }
    ];

    gaps = {
      inner = {
        horizontal = 16;
        vertical = 16;
      };
      outer = {
        top = 16;
        right = 16;
        bottom = 16;
        left = 16;
      };
    };

    mode.main.binding = {
      alt-h = "focus left";
      alt-j = "focus down";
      alt-k = "focus up";
      alt-l = "focus right";

      alt-r = "layout floating tiling";
      alt-enter = "fullscreen";

      alt-shift-h = "move left";
      alt-shift-j = "move down";
      alt-shift-k = "move up";
      alt-shift-l = "move right";

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
  };
}
