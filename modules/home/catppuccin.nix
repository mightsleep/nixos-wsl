# One palette for starship, bat, btop, fzf, lazygit, fish and nushell
{inputs, ...}: {
  flake.modules.homeManager.catppuccin = {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      # neovim has its own theme in nvf
      nvim.enable = false;
    };
  };
}
