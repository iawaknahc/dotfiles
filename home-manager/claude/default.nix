{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    # From the overlay of natsukium/mcp-servers-nix
    #
    # As of 2025-06-08, Playwright supports full page screenshot out-of-the-box.
    # https://playwright.dev/docs/screenshots#full-page-screenshots
    # But @playwright/mcp does not expose that
    # https://github.com/microsoft/playwright-mcp/blob/v0.0.28/src/tools/screenshot.ts
    playwright-mcp

    # The steps to update this package.
    # 1. git-clone the source code.
    # 2. git-checkout the version.
    # 3. See if rg.patch is still needed.
    # 4. Reference ./rg.patch and replicate it in the version.
    # 5. Update ./rg.patch
    # 6. Update the hashes.
    (buildNpmPackage rec {
      pname = "desktop-commander";
      version = "0.2.3";

      src = fetchFromGitHub {
        owner = "wonderwhy-er";
        repo = "DesktopCommanderMCP";
        rev = "v${version}";
        hash = "sha256-6HuKpWfwwWb4kSsr1vuR7NcIMQpUTqdzXBkqazGJEVc=";
      };

      npmDepsHash = "sha256-b9apk3NdAQiZc5kbtpVbkKBbx8n+QlewrvXBbpfJaQw=";

      # We need to remove the dependency on @vscode/ripgrep because
      # it contains a postinstall script that is not compatible with Nix.
      # In the postinstall script, it downloads a prebuilt binary of ripgrep.
      # In Nix, we can replicate the behavior easily.
      patches = [ ./rg.patch ];
      postPatch = ''
        sed -i 's|@rgPath@|${ripgrep}/bin/rg|g' src/tools/search.ts
      '';
    })
  ];

  home.file.".claude/CLAUDE.md".text = ''
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
  '';

  # https://modelcontextprotocol.io/quickstart/user#2-add-the-filesystem-mcp-server
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON {
      # Avoid conflict with Alfred.
      globalShortcut = "Shift+Alt+Space";
      mcpServers = {
        playwright = {
          command = "${config.home.profileDirectory}/bin/mcp-server-playwright";
        };

        desktop-commander = {
          command = "${config.home.profileDirectory}/bin/desktop-commander";
        };

        # mcp-server-time is very limited.
        # On Claude Code, it is better ask to the Bash tool to do time related manipulation.
        # On Claude Desktop, it can use desktop-commander to run shell commands.

        # No need to install mcp-server-fetch because Claude Desktop and Claude Code has it built in.
      };
    };
  };

  # It is impossible to do the same for Claude Code because
  # Claude Code stores all of its config and state in ~/.claude.json
  # We cannot manage ~/.claude.json with home-manager as Claude Code will write it from time to time.
}
