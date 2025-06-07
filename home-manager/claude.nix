{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (writeScriptBin "mcp-server-time" ''
      #!/bin/sh
      ${config.home.profileDirectory}/bin/uvx mcp-server-time "$@"
    '')
  ];

  # https://modelcontextprotocol.io/quickstart/user#2-add-the-filesystem-mcp-server
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON {
      mcpServers = {
        time = {
          command = "${config.home.profileDirectory}/bin/mcp-server-time";
          args = [
            # For some unknown reason, the timezone name it detects is HKT,
            # which is not a valid entry in the tz database.
            # Therefore we provide an accurate one.
            "--local-timezone"
            "Asia/Hong_Kong"
          ];
        };
        # No need to install mcp-server-fetch because Claude Desktop and Claude Code has it built in.
      };
    };
  };

  # It is impossible to do the same for Claude Code because
  # Claude Code stores all of its config and state in ~/.claude.json
  # We cannot manage ~/.claude.json with home-manager as Claude Code will write it from time to time.
}
