{ pkgs, ... }:
let
  date = "iso8601-strict-local";
  # We do not pass any flags to less because we assume LESS is defined in the shell.
  # See ./pager.nix
  pager = "less";
in
{
  programs.git.enable = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";

  home.packages = with pkgs; [
    # blackbox was removed from nixpkgs after nixos-25.11
    # blackbox
    difftastic
    delta
  ];
  home.sessionVariables = {
    # Turn off the syntax highlighting of difftastic.
    DFT_SYNTAX_HIGHLIGHT = "off";
  };

  programs.git.attributes = [
    # blackbox was removed from nixpkgs after nixos-25.11
    # "*.gpg diff=blackbox"
    # "trustdb.gpg !diff"
  ];

  programs.git.ignores = [
    ".DS_Store"
  ];

  programs.git.settings = {
    alias = {
      alias-ls-files-only-ignored = "ls-files --others --ignored --exclude-standard";
      alias-ls-files-only-untracked = "ls-files --others --exclude-standard";
      # The following aliases are expected to be run with -n or -f.
      alias-clean-only-untracked = "clean -d";
      alias-clean-only-ignored = "clean -dX";
      alias-clean-both-untracked-and-ignored = "clean -dx";

      diffd = "-c pager.difftool= difftool -t nvim --dir-diff"; # The "d" in "diffd" means directory.
      logs = "-c pager.log='${pager}' -c diff.external=difft log --ext-diff --patch"; # The "s" in "logs" means structural.
      shows = "-c pager.show='${pager}' -c diff.external=difft show --ext-diff"; # The "s" in "shows" means structural.
    };
    blame = {
      # Use the same date format as git-log(1)
      date = date;
    };
    clean = {
      # This is the default.
      requireForce = true;
    };
    commit = {
      # Show git diff --cached and git diff at the end of the commit message template.
      # https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---verbose
      verbose = 2;
    };
    core = {
      pager = "delta";
    };
    delta = {
      # Suppress all structural modification by delta.
      color-only = true;
      # Suppress syntax highlighting.
      syntax-theme = "none";

      # The default color of git is not documented,
      # but it can be found in the source code.
      # See https://github.com/git/git/blob/v2.54.0/diff.c#L83-L104
      #
      # delta supports --color-moved,
      # but it does not introduce new styles for it.
      # Instead, it detects the extra colors emitted by --color-moved,
      # and display them verbatim.
      # This implies when there is a changed line in a block of moved lines,
      # there is no word-diff highlighting.
      # See https://dandavison.github.io/delta/color-moved-support.html
      #
      # If our goal is to make delta displays as close as possible to the original, we just need to customize the available styles.
      # Run `delta --show-config` to see the list of available styles.
      # It may be tempting to use `raw` to keep the original color, but it does not work as expected.
      # For example, you may want to set `minus-style` to `raw`, and `minus-emph-style` to `reverse red`.
      # The result is that the lines have no word-diff highlighting.
      # I haven't looked at the source code of delta but I guess this is due to `raw` causing delta not to parse the line at all, skipping the word-diff highlighting.
      # So we have to restore the original color and change only the `*-emph-style`.
      # Thanks to the link above we can look at the source code of git to know the original colors.
      #
      # There are 2 ways to set `*-emph-style`: `reverse` and `bold`.
      # I noticed that difftastic uses `bold` so I followed it.
      zero-style = "raw";
      minus-style = "red";
      minus-emph-style = "bold red";
      minus-empty-line-marker-style = "red";
      plus-style = "green";
      plus-emph-style = "bold green";
      plus-empty-line-marker-style = "green";
      whitespace-error-style = "reverse red";
    };
    diff = {
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-diffalgorithm
      algorithm = "histogram";

      # The interesting values are `plain`, `zebra`, and `dimmed-zebra`.
      #
      # `dimmed-zebra` cause moved lines to grey out, which I do not think is good for reading.
      #
      # `zebra` uses a change in color to indicate a new block is detected.
      # So there are in total 4 new colors.
      # That is a little bit overwhelming to me.
      #
      # `plain` uses 2 new colors.
      # It is cognitively easier to understand.
      # https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---color-movedmode
      colorMoved = "plain";

      # This config accepts comma separated values.
      # But `allow-indentation-change` is incompatible with other modes so it has to be on its own.
      # It, nevertheless, should be the most useful mode.
      # Its effect is that when a block of code is moved AND the indentation has changed,
      # it is still considered as a move.
      # https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---color-moved-wsmode
      colorMovedWS = "allow-indentation-change";

      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-diffmnemonicPrefix
      mnemonicPrefix = true;
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-diffrenames
      renames = "copy";

      # We need to specify a default tool, otherwise, git will use vimdiff.
      tool = "difft";

      # This diff driver CANNOT be used together with difftastic!
      blackbox = {
        textconv = "gpg --quiet --batch --decrypt";
      };
    };
    difftool = {
      prompt = false;
      trustExitCode = true;

      # Difftastic does not support --color-moved.
      # See https://github.com/Wilfred/difftastic/issues/520
      difft = {
        cmd = ''difft "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
      };

      # Never use a pager with nvim.
      # It will break.
      #
      # Even though we managed to get it work by disabling the pager,
      # the experience of `git difftool -t nvim` is still suboptimal.
      # nvim is invoked once for each file.
      # After we quit, git will open a new instance of nvim to view the diff of the next file, until there are no more files to view.
      # This can be worked around by using --dir-diff
      # With --dir-diff, nvim is invoked once on two directories, and
      # this is exactly what :DiffTool is designed to handle.
      #
      # This concludes that the correct invocation is `git difftool -t nvim --dir-diff`,
      # which is not something we want to type in the command-line.
      # It should be an alias instead.
      # This implies `diff.tool` should never be set to `nvim`, and
      # `pager.difftool` should be set to value that works best for `diff.tool`.
      nvim = {
        cmd = ''nvim -d "$LOCAL" "$REMOTE"'';
      };
    };
    format = {
      # This is the default.
      # I have tried `fuller` https://git-scm.com/docs/git-log#Documentation/git-log.txt-fuller
      # Most of the time the author is the same as the committer, so the additional information is quite redundant.
      pretty = "medium";
    };
    init = {
      defaultBranch = "main";
    };
    log = {
      # Print `refs/head/`, `refs/remotes/`, and `refs/tags/`.
      decorate = "full";
      date = date;
    };
    merge = {
      # Always be explicit.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergedefaultToUpstream
      defaultToUpstream = false;
      # Make git merge --no-ff by default.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergeff
      ff = false;
      # Show the original text indicated by ||||||| before =======
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergeconflictStyle
      conflictStyle = "zdiff3";
    };
    pager = {
      # Some difftool like difftastic requires a pager,
      # while some like nvim does not.
      # Set it a value that works best for `diff.tool`.
      difftool = pager;
    };
    push = {
      # Always be explicit.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefault
      default = "nothing";
    };
    rebase = {
      # Forbid accidentally removed lines in git rebase -i
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rebasemissingCommitsCheck
      missingCommitsCheck = "error";
    };
    user = {
      # Always be explicit
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-useruseConfigOnly
      useConfigOnly = true;
    };
    url = {
      # Ask git to always use ssh instead of https
      # This config conflicts with cr, see https://github.com/helm/chart-releaser/issues/124
      "ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
    };
  };
}
