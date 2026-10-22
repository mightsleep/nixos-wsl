# User with fish as login shell, home-manager wiring
{
  inputs,
  config,
  ...
}: let
  inherit (config) username;
in {
  flake.modules.nixos.users = {pkgs, ...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    programs.fish.enable = true;

    users.users.${username} = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      shell = pkgs.fish;
    };
    # WSL logs you in directly, there is no password to type for sudo
    security.sudo.wheelNeedsPassword = false;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.${username}.home.stateVersion = "26.05";
    };
  };
}
