{ pkgs, ... }:
let
  date = "iso8601-strict-local";
in
{
  programs.git.enable = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";

  home.packages = with pkgs; [
    # blackbox was removed from nixpkgs after nixos-25.11
    # blackbox
    difftastic
  ];
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
      alias-difft-log = "-c diff.external=difft log --ext-diff --patch";
      alias-difft-show = "-c diff.external=difft show --ext-diff";
      alias-ls-files-only-ignored = "ls-files --others --ignored --exclude-standard";
      alias-ls-files-only-untracked = "ls-files --others --exclude-standard";
      # The following aliases are expected to be run with -n or -f.
      alias-clean-only-untracked = "clean -d";
      alias-clean-only-ignored = "clean -dX";
      alias-clean-both-untracked-and-ignored = "clean -dx";
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
      # git diff is unchanged.
      # This changes git difftool only.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-difftool
      tool = "difftastic";

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
      difftastic = {
        cmd = ''difft "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
      };

      # In my test on 2026-04-01, it does not work for `git difftool --cached` inside tmux with an index of several files.
      nvim_difftool = {
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
      difftool = true;
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
