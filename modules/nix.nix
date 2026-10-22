# Nix daemon settings and nh
{config, ...}: {
  flake.modules.nixos.nix = {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes" "pipe-operators"];
        # The 1 MiB default stalls downloads well below line speed
        download-buffer-size = 256 * 1024 * 1024;
        # Corporate proxies like to hold connections open without data
        stalled-download-timeout = 60;
        download-attempts = 5;
        warn-dirty = false;
        trusted-users = ["root" "@wheel"];
        substituters = ["https://catppuccin.cachix.org"];
        trusted-public-keys = ["catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="];
      };
      # GC is handled by nh clean
      gc.automatic = false;
      optimise.automatic = true;
    };

    programs.nh = {
      enable = true;
      flake = "/home/${config.username}/nixos-wsl";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
  };
}
