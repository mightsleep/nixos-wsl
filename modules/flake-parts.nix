# Flake skeleton: every file in modules/ is a flake-parts module (import-tree).
# Features live in `flake.modules.<class>.<name>`; hosts.nix imports all of them,
# so a new feature is just a new file. Other flakes can pick single modules.
{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.modules];

  options.username = lib.mkOption {
    type = lib.types.str;
    default = "michal";
    description = "Default WSL user. Changing it on an installed system needs `nixos-rebuild boot`, see README.";
  };

  config = {
    systems = ["x86_64-linux"];

    perSystem = {pkgs, ...}: {
      formatter = pkgs.alejandra;

      checks.lint =
        pkgs.runCommand "lint" {
          nativeBuildInputs = [pkgs.alejandra pkgs.statix pkgs.deadnix];
        } ''
          cd ${inputs.self}
          alejandra --check --quiet .
          statix check .
          deadnix --fail .
          touch $out
        '';
    };
  };
}
