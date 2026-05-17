{
  config,
  ...
}:
let
  AGENTS_md = ".coding-agent/AGENTS.md";
in
{
  xdg.configFile."${AGENTS_md}".text = ''
    ## Date format

    Unless otherwise specified, output date and time in ISO 8601 format.

    Examples:
    - `2006-01-02`
    - `2006-01-02T15:04:05Z`
    - `2006-01-02T15:04:05.999+07:00`
  '';

  programs.claude-code.context = config.xdg.configFile."${AGENTS_md}".text;
  home.file.".pi/agent/AGENTS.md".text = config.xdg.configFile."${AGENTS_md}".text;
}
