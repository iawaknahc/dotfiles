{ pkgs, ... }:
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
    ".envrc"
    ".direnv/"
    ".claude/settings.local.json" # https://code.claude.com/docs/en/settings#available-scopes
  ];

  programs.git.settings = {
    alias = {
      alias-difft-log = "-c diff.external=difft log --ext-diff --patch";
      alias-difft-show = "-c diff.external=difft show --ext-diff";
      alias-ls-files-only-ignored = "ls-files --others --ignored --exclude-standard";
      alias-ls-files-only-untracked = "ls-files --others --exclude-standard";
      # The following aliases are expected to be run with -n or -f.
      alias-clean-only-ignored = "clean -dX";
      alias-clean-both-untracked-and-ignored = "clean -dx";
    };
    clean = {
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
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-diffmnemonicPrefix
      mnemonicPrefix = true;
      # git diff is unchanged.
      # This changes git difftool only.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-difftool
      tool = "difftastic";

      # This diff driver CANNOT be used together with difftastic!
      blackbox = {
        textconv = "gpg --quiet --batch --decrypt";
      };
    };
    pager = {
      difftool = true;
    };
    difftool = {
      prompt = false;
      trustExitCode = true;

      difftastic = {
        cmd = ''difft "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
      };

      # In my test on 2026-04-01, it does not work for `git difftool --cached` inside tmux with an index of several files.
      nvim_difftool = {
        cmd = ''nvim -d "$LOCAL" "$REMOTE"'';
      };
    };
    init = {
      defaultBranch = "main";
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
