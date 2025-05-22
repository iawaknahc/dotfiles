{ pkgs, ... }:
{
  programs.git.enable = true;

  home.packages = with pkgs; [
    blackbox
    difftastic
  ];
  programs.git.attributes = [
    "*.gpg diff=blackbox"
    "trustdb.gpg !diff"
  ];

  programs.git.ignores = [
    ".DS_Store"
    ".envrc"
    ".direnv/"
  ];

  programs.git.aliases = {
    dlog = "-c diff.external=difft log --ext-diff --patch";
    dshow = "-c diff.external=difft show --ext-diff";
  };

  programs.git.extraConfig = {
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
    };
    merge = {
      # Always be explicit.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergedefaultToUpstream
      defaultToUpstream = false;
      # Make git merge --no-ff by default.
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergeff
      ff = false;
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
