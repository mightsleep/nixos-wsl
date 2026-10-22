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

          # Catppuccin mocha in truecolor: the terminal's ANSI magenta is pink in mocha
          colors = {
            "change_id prefix" = {
              fg = "#89b4fa";
              bold = true;
            };
            "change_id rest" = "#6c7086";
            "working_copy change_id prefix" = {
              fg = "#89b4fa";
              bold = true;
            };
            "working_copy change_id rest" = "#6c7086";
            "commit_id" = "#6c7086";
            "working_copy commit_id" = "#9399b2";
            "description" = "#cdd6f4";
            "working_copy description" = "#cdd6f4";
            "working_copy empty description placeholder" = "#a6adc8";
            "bookmarks" = {
              fg = "#a6e3a1";
              bold = true;
            };
            "working_copy bookmarks" = {
              fg = "#a6e3a1";
              bold = true;
            };
            "tags" = "#94e2d5";
            "timestamp" = "#74c7ec";
            "email" = "#a6e3a1";
            "working_copy email" = "#a6e3a1";
            "empty" = {
              fg = "#f9e2af";
              bold = true;
            };
            "conflict" = {
              fg = "#f38ba8";
              bold = true;
            };
            "diff added" = "#a6e3a1";
            "diff removed" = "#f38ba8";
            "diff modified" = "#f9e2af";
            "diff file_header" = {
              fg = "#89b4fa";
              bold = true;
            };
            "node working_copy" = {
              fg = "#cba6f7";
              bold = true;
            };
          };

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
