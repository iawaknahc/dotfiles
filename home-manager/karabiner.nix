{ pkgs, lib, ... }:
let
  remap = from_key_code: to_key_code: {
    from = {
      key_code = from_key_code;
    };
    to = [
      {
        key_code = to_key_code;
      }
    ];
  };
  typeSymbol =
    key_code: text:
    let
      modifiers = [ "right_option" ];
    in
    {
      description = "Type ${text} with ${builtins.concatStringsSep " + " modifiers} + ${key_code}";
      manipulators = [
        {
          type = "basic";
          from = {
            inherit key_code;
            modifiers = {
              mandatory = modifiers;
            };
          };
          to = [
            {
              shell_command = "${pkgs.hs}/bin/hs -c 'hs.eventtap.keyStrokes(_cli.args[2])' -- ${lib.escapeShellArg text}";
            }
          ];
        }
      ];
    };
  karabinerJSON = {
    profiles = [
      {
        selected = true;
        name = "default-profile";
        virtual_hid_keyboard = {
          keyboard_type_v2 = "ansi";
        };
        devices = [
          {
            # My FILCO keyboard.
            # We need this because the builtin remap offered by macOS no longer works
            # when Karabiner is running.
            identifiers = {
              is_keyboard = true;
              product_id = 30738;
              vendor_id = 12029;
            };
            simple_modifications = [
              (remap "left_option" "left_command")
              (remap "left_command" "left_option")
              (remap "right_option" "right_command")
              (remap "right_command" "right_option")
            ];
          }
        ];
        complex_modifications = {
          rules = [
            # The following mappings do not override existing ones.
            # For example, we DO NOT map right_option + 1 to 1️⃣  because right_option + 1 maps to ¡ by default.
            (typeSymbol "left_command" "⌘")
            (typeSymbol "right_command" "⌘")
            (typeSymbol "left_option" "⌥")
            (typeSymbol "left_control" "⌃")
            (typeSymbol "right_control" "⌃")
            (typeSymbol "left_shift" "⇧")
            (typeSymbol "right_shift" "⇧")
            (typeSymbol "escape" "␛")
            (typeSymbol "return_or_enter" "⏎")
            (typeSymbol "tab" "⇥")
            (typeSymbol "caps_lock" "⇪")
            (typeSymbol "spacebar" "␣")
            (typeSymbol "delete_or_backspace" "⌫")
            (typeSymbol "up_arrow" "↑")
            (typeSymbol "right_arrow" "→")
            (typeSymbol "down_arrow" "↓")
            (typeSymbol "left_arrow" "←")
          ];
        };
      }
    ];
  };
in
{
  xdg.configFile."karabiner/karabiner.json" = {
    enable = true;
    source =
      let
        jsonString = builtins.toJSON karabinerJSON;
        pathToJSONFile = pkgs.writeText "karabiner.json" jsonString;
        pathToPrettyJSON = pkgs.runCommand "karabiner.json" { } ''
          ${pkgs.jq}/bin/jq <${pathToJSONFile} >$out
        '';
      in
      pathToPrettyJSON;
  };
}
