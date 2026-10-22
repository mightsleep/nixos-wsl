# command-not-found that knows nixpkgs, plus `, foo` to run anything once
{inputs, ...}: {
  flake.modules.homeManager.nix-index = {
    imports = [inputs.nix-index-database.homeModules.nix-index];
    programs.nix-index-database.comma.enable = true;
  };
}
