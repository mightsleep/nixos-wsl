# git, jj, difftastic, gh.
# No global email on purpose: set it per repo
# (`jj config set --repo user.email ...`), work and OSS identities differ.
{
  flake.modules.homeManager.vcs = {pkgs, ...}: {
    home.packages = [pkgs.jjui];

    programs = {
      git = {
        enable = true;
        settings = {
          user.name = "mightsleep";
          init.defaultBranch = "main";
          pull.rebase = true;
          # Windows checkouts on /mnt/c otherwise show every file as modified
          core.autocrlf = "input";
        };
      };

      jujutsu = {
        enable = true;
        settings = {
          user.name = "mightsleep";

          ui = {
            default-command = "log";
            diff-editor = ":builtin";
            pager = ["bat" "--plain"];
          };

          remotes.origin.auto-track-bookmarks = "*";

          aliases = {
            c = ["commit"];
            d = ["diff"];
            l = ["log"];
            la = ["log" "-r" "::"];
            s = ["squash"];
            e = ["edit"];
            f = ["git" "fetch"];
            p = ["git" "push"];
            # Move the closest bookmark up to the last pushable commit
            tug = ["bookmark" "move" "--from" "closest(@-)" "--to" "closest_pushable(@)"];
          };

          revset-aliases = {
            "closest(to)" = "heads(::to & bookmarks())";
            "closest_pushable(to)" = ''heads(::to & ~description(exact:"") & (~empty() | merges()))'';
          };
        };
      };

      difftastic = {
        enable = true;
        git.enable = true;
        jujutsu.enable = true;
      };

      # HTTPS to GitHub goes over 443, which every corporate network lets through
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
  };
}
