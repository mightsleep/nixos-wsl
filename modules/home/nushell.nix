# Nushell next to fish: `nu` when you want tables, fish stays the login shell
{
  flake.modules.homeManager.nushell = {
    config,
    pkgs,
    ...
  }: {
    programs = {
      nushell = {
        enable = true;
        # home.sessionVariables only reach POSIX shells and fish
        environmentVariables = {inherit (config.home.sessionVariables) EDITOR;};
        settings = {
          show_banner = false;
          history = {
            file_format = "sqlite";
            max_size = 1000000;
          };
          completions.algorithm = "fuzzy";
          table = {
            mode = "rounded";
            header_on_separator = true;
          };
          highlight_resolved_externals = true;
        };
        shellAliases = {
          la = "ls --all";
          ll = "eza -la --icons";
          cat = "bat";
        };
        extraConfig = ''
          # Completions for externals from zsh/fish/bash where carapace has no spec
          $env.CARAPACE_BRIDGES = "zsh,fish,bash"

          # mkdir + cd
          def --env mc [path: path]: nothing -> nothing {
            mkdir $path
            cd $path
          }
        '';
      };

      carapace.enable = true;
    };

    # Only so the zsh bridge of carapace has something to read
    home.packages = [pkgs.zsh];
  };
}
