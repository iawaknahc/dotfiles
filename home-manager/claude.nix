{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    # From the overlay of natsukium/mcp-servers-nix
    mcp-server-time

    # From the overlay of natsukium/mcp-servers-nix
    #
    # As of 2025-06-08, Playwright supports full page screenshot out-of-the-box.
    # https://playwright.dev/docs/screenshots#full-page-screenshots
    # But @playwright/mcp does not expose that
    # https://github.com/microsoft/playwright-mcp/blob/v0.0.28/src/tools/screenshot.ts
    playwright-mcp
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
        playwright = {
          command = "${config.home.profileDirectory}/bin/mcp-server-playwright";
        };

        # No need to install mcp-server-fetch because Claude Desktop and Claude Code has it built in.
      };
    };
  };

  # It is impossible to do the same for Claude Code because
  # Claude Code stores all of its config and state in ~/.claude.json
  # We cannot manage ~/.claude.json with home-manager as Claude Code will write it from time to time.
}
