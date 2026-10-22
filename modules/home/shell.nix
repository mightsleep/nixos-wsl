# fish (login shell), direnv, zoxide and the usual CLI suspects
{
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home = {
      sessionVariables.EDITOR = "nvim";
      packages = [
        pkgs.ripgrep
        pkgs.fd
        pkgs.jq
        pkgs.tldr
        pkgs.dust
        pkgs.hyperfine
        pkgs.fastfetch
      ];
    };

    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
        '';
        shellAliases = {
          ls = "eza --icons";
          ll = "eza -la --icons";
          lt = "eza -T --icons";
          cat = "bat";
        };
        plugins = [
          {
            name = "fzf-fish";
            inherit (pkgs.fishPlugins.fzf-fish) src;
          }
        ];
      };

      bat.enable = true;
      # As programs, not packages: only then catppuccin themes them
      btop.enable = true;
      eza = {
        enable = true;
        # Aliases are ours (above), with --icons
        enableFishIntegration = false;
        enableNushellIntegration = false;
      };
      fzf.enable = true;
      lazygit.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      zoxide.enable = true;
      # `nix develop` and `nix shell` drop into fish instead of bash
      nix-your-shell.enable = true;
    };
  };
}
