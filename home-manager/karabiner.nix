{ pkgs, lib, ... }:
let
  typeRule =
    {
      modifiers,
      key_code,
      text,
    }:
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
              shell_command =
                let
                  encodedText = lib.strings.escapeURL text;
                  url = lib.escapeShellArg "hammerspoon://type?text=${encodedText}";
                in
                "open -g ${url}";
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
        complex_modifications = {
          rules = [
            # The following mappings do not override existing ones.
            # For example, we DO NOT map right_option + 1 to 1️⃣  because right_option + 1 maps to ¡ by default.
            (typeRule {
              modifiers = [ "right_option" ];
              key_code = "left_command";
              text = "⌘";
            })
            (typeRule {
              modifiers = [ "right_option" ];
              key_code = "left_option";
              text = "⌥";
            })
            (typeRule {
              modifiers = [ "right_option" ];
              key_code = "left_control";
              text = "⌃";
            })
            (typeRule {
              modifiers = [ "right_option" ];
              key_code = "left_shift";
              text = "⇧";
            })
            (typeRule {
              modifiers = [ "right_option" ];
              key_code = "escape";
              text = "␛";
            })
            (typeRule {
              modifiers = [ "right_option" ];
              key_code = "return_or_enter";
              text = "⏎";
            })
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
