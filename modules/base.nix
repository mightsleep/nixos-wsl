# Nothing implicit: NixOS adds perl, rsync, strace and nano to every system.
# What we want stays, listed explicitly.
{
  flake.modules.nixos.base = {pkgs, ...}: {
    environment.defaultPackages = [];
    programs.nano.enable = false;

    # strace lives in debug.nix
    environment.systemPackages = [pkgs.rsync];
  };
}
