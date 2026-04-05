{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    # From the overlay of natsukium/mcp-servers-nix
    #
    # As of 2025-06-08, Playwright supports full page screenshot out-of-the-box.
    # https://playwright.dev/docs/screenshots#full-page-screenshots
    # But @playwright/mcp does not expose that
    # https://github.com/microsoft/playwright-mcp/blob/v0.0.28/src/tools/screenshot.ts
    playwright-mcp

    # From the overlay of natsukium/mcp-servers-nix
    context7-mcp
  ];
  programs.mcp.enable = true;
  programs.mcp.servers = {
    playwright = {
      command = "${config.home.profileDirectory}/bin/mcp-server-playwright";
    };
    context7 = {
      command = "${config.home.profileDirectory}/bin/context7-mcp";
    };
  };

  programs.claude-code.enable = true;
  programs.claude-code.enableMcpIntegration = true;
  programs.claude-code.memory.text = ''
    # CLAUDE.md

    ## Use Bash tool

    Try using your Bash tool when you lack the ability to do something relevant to your task.

    Here are some examples:

    - In a Python script, you gain access to a cryptographically secure RNG.
    - In a Python script, you gain access to datetime utility and calendar manipulation.

    ## Date format

    Unless otherwise specified, output date and time in ISO 8601 format.

    Examples:
    - `2006-01-02`
    - `2006-01-02T15:04:05Z`
    - `2006-01-02T15:04:05.999+07:00`

    ## Reading PDF files

    In case you cannot read PDF files, you should use the markitdown tool to do so.

    ## Manipulate PDF files

    Use poppler-utils instead of pdftk to manipulate PDF files.
  '';

  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON {
      preferences = {
        quickEntryShortcut = "off";
      };
    };
  };
}
