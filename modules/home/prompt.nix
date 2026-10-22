# Prompt in the style of nushell's default: green path, `> `, time on the right.
# Nu keeps its own prompt and only gets the VCS segment appended, fish copies the look.
# The segment is one script for both shells: jj first, plain git as a fallback.
{
  flake.modules.homeManager.prompt = {pkgs, ...}: let
    # --ignore-working-copy: no snapshot on every prompt, so it stays fast in big
    # repos and doesn't add operations; `empty` is as of the last jj command
    vcsPrompt = pkgs.writeShellApplication {
      name = "vcs-prompt";
      runtimeInputs = [pkgs.jujutsu pkgs.git];
      text = ''
        if jj root --ignore-working-copy >/dev/null 2>&1; then
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
        printf '\e[35m%s\e[0m' "$branch"
      '';
    };
  in {
    home.packages = [vcsPrompt];

    programs.fish.functions = {
      fish_prompt = ''
        set -l path (set_color green --bold)
        set -l sep (set_color brgreen --bold)
        if fish_is_root_user
          set path (set_color red --bold)
          set sep (set_color brred --bold)
        end
        set -l dir (string replace -r "^$HOME" "~" -- $PWD)
        echo -n $path(string replace -a / "$sep/$path" -- $dir)(set_color normal)
        set -l vcs (vcs-prompt)
        test -n "$vcs"; and echo -n " $vcs"
        echo -n "> "
      '';
      fish_right_prompt = ''
        set -l code $status
        test $code -ne 0; and echo -n (set_color red --bold)$code" "
        set -l now (date '+%x %X')
        echo -n (set_color magenta)(string replace -ra '([/:.])' (set_color green)'$1'(set_color magenta) -- $now)(set_color normal)
      '';
      # Vi mode etc. would draw [I] in front of the prompt
      fish_mode_prompt = "";
    };

    programs.nushell.extraConfig = ''
      # Default prompt + VCS segment. A closure scope: the jj call
      # does not touch LAST_EXIT_CODE for the right prompt.
      let default_prompt = $env.PROMPT_COMMAND
      $env.PROMPT_COMMAND = {||
        let vcs = (^vcs-prompt)
        if ($vcs | is-empty) { do $default_prompt } else { $"(do $default_prompt) ($vcs)" }
      }
    '';
  };
}
