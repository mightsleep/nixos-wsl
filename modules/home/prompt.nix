# Two-line prompt, the laptop's starship layout as plain text with Nerd Font glyphs:
#    user  󰉋 ~/path  󱗆 jj
#   ❯
# The VCS segment is one script for fish and nu: jj first, plain git as a fallback.
{
  flake.modules.homeManager.prompt = {pkgs, ...}: let
    # --ignore-working-copy: no snapshot on every prompt, so it stays fast in big
    # repos and doesn't add operations; `empty` is as of the last jj command
    vcsPrompt = pkgs.writeShellApplication {
      name = "vcs-prompt";
      runtimeInputs = [pkgs.jujutsu pkgs.git];
      text = ''
        if jj root --ignore-working-copy >/dev/null 2>&1; then
          printf '\e[1;38;2;203;166;247m\U000f15c6\e[0m '
          exec jj log --ignore-working-copy --no-graph --color always -r @ -T '
            separate(" ",
              change_id.shortest(4),
              bookmarks,
              if(conflict, label("conflict", "conflict")),
              if(empty, label("empty", "empty")),
            )'
        fi
        branch=$(git branch --show-current 2>/dev/null) || exit 0
        [ -n "$branch" ] || branch=$(git rev-parse --short HEAD 2>/dev/null) || exit 0
        printf '\e[1;38;2;203;166;247m %s\e[0m' "$branch"
      '';
    };
  in {
    home.packages = [vcsPrompt];

    programs.fish.functions = {
      fish_prompt = ''
        set -l code $status
        set -l user_color blue
        fish_is_root_user; and set user_color red

        echo -n -s (set_color $user_color --bold)  " " $USER "  " \
          (set_color green --bold) \U000f024b " " (prompt_pwd -d 0) (set_color normal)
        set -l vcs (vcs-prompt)
        test -n "$vcs"; and echo -n "  $vcs"
        echo

        set -l char_color green
        test $code -ne 0; and set char_color red
        echo -n -s (set_color $char_color --bold) "❯ " (set_color normal)
      '';
      # Only a non-zero exit code, no clock
      fish_right_prompt = ''
        set -l code $status
        test $code -ne 0; and echo -n (set_color red --bold)$code(set_color normal)
      '';
      # Vi mode etc. would draw [I] in front of the prompt
      fish_mode_prompt = "";
    };

    # Same layout for nu. Each prompt closure has its own scope, so the
    # vcs-prompt call does not touch LAST_EXIT_CODE for the indicator.
    programs.nushell.extraConfig = ''
      $env.PROMPT_COMMAND = {||
        let user_color = if (is-admin) { "red_bold" } else { "blue_bold" }
        let dir = $env.PWD | str replace $nu.home-dir "~"
        let vcs = ^vcs-prompt
        let line = $"(ansi $user_color)(char -u f313) ($env.USER)  (ansi green_bold)(char -u f024b) ($dir)(ansi reset)"
        if ($vcs | is-empty) { $line + "\n" } else { $"($line)  ($vcs)\n" }
      }
      $env.PROMPT_COMMAND_RIGHT = {||
        let code = $env.LAST_EXIT_CODE? | default 0
        if $code != 0 { $"(ansi red_bold)($code)(ansi reset)" } else { "" }
      }
      $env.PROMPT_INDICATOR = {||
        if ($env.LAST_EXIT_CODE? | default 0) == 0 { $"(ansi green_bold)❯ (ansi reset)" } else { $"(ansi red_bold)❯ (ansi reset)" }
      }
    '';
  };
}
