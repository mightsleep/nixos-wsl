# `nix run github:mightsleep/nixos-wsl`: install this flake on a fresh NixOS-WSL.
# Builds from the store copy of the flake, so it needs no git and no clone.
{
  self,
  config,
  ...
}: {
  perSystem = {pkgs, ...}: {
    apps.default = {
      type = "app";
      meta.description = "Install this configuration on a fresh NixOS-WSL";
      program = pkgs.writeShellApplication {
        name = "bootstrap";
        text = ''
          target=${config.username}
          rebuild() {
            sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
              nixos-rebuild "$1" --flake ${self}#wsl
          }

          if [ "$(id -un)" = "$target" ]; then
            rebuild switch
            echo "Done. Clone the repo to ~/nixos-wsl to edit it, then: nh os switch"
            exit 0
          fi

          # A new default user must not be activated with switch, see
          # https://nix-community.github.io/NixOS-WSL/how-to/change-username.html
          rebuild boot
          cat <<EOF

          Built. The default user changes from $(id -un) to $target on restart.
          Run in PowerShell:

            wsl -t NixOS
            wsl -d NixOS --user root exit
            wsl -t NixOS
            wsl -d NixOS

          Then clone the repo to ~/nixos-wsl and use: nh os switch
          EOF
        '';
      };
    };
  };
}
