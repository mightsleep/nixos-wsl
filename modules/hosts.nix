# Hosts: compose every nixos and homeManager module.
# wsl-ephemeral is the same system with / wiped on every start (ephemeral.nix);
# try it on a copy of the distro first.
{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (config.flake) modules;

  mkWsl = extra:
    inputs.nixpkgs.lib.nixosSystem {
      modules =
        lib.attrValues modules.nixos
        ++ [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            networking.hostName = "wsl";
            home-manager.sharedModules = lib.attrValues modules.homeManager;
            # The release NixOS-WSL was installed from; do not bump on upgrades
            system.stateVersion = "26.05";
          }
          extra
        ];
    };

  wsl = mkWsl {};
  wsl-ephemeral = mkWsl {ephemeral.enable = true;};
in {
  flake.nixosConfigurations = {inherit wsl wsl-ephemeral;};

  perSystem = {system, ...}:
    lib.optionalAttrs (system == "x86_64-linux") {
      checks = {
        toplevel = wsl.config.system.build.toplevel;
        toplevel-ephemeral = wsl-ephemeral.config.system.build.toplevel;
      };
    };
}
