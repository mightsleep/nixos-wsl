# nixos-wsl

NixOS on WSL2 for a work laptop: fish, neovim, git + jj, a network toolbox.
My personal setup, shared as is. Fork it and change the user.

## Install

1. In PowerShell: `wsl --install --no-distribution`, restart.
2. Download `nixos.wsl` from [Releases](https://github.com/mightsleep/nixos-wsl/releases/latest) and double-click it.
3. Inside WSL:

   ```sh
   git clone https://github.com/mightsleep/nixos-wsl ~/nixos-wsl
   nh os switch ~/nixos-wsl
   ```

Already on NixOS-WSL? `nix --extra-experimental-features 'nix-command flakes' run github:mightsleep/nixos-wsl`
and follow what it prints.

## Make it yours

- `username` in `modules/flake-parts.nix`, `user.name` in `modules/home/vcs.nix`.
- One file in `modules/` is one feature. Delete a file to drop it, add one to add it.
- Behind a corporate proxy or VPN: [docs/corporate-network.md](docs/corporate-network.md).

## Checks

```sh
nix fmt
nix build --keep-going .#checks.x86_64-linux.lint .#checks.x86_64-linux.toplevel
```

A `v*` tag builds `nixos.wsl` into a release.
