# Impermanence for WSL: every distro start wipes / and keeps only what is listed.
#
# There is no initrd on WSL. WSL mounts / from the vhdx and runs /sbin/init, which
# NixOS-WSL points at its shim (activation, then systemd). We put a wrapper in front
# of the shim: wipe, bind mounts from /persist, exec the shim. The bind mounts happen
# here, not in systemd, because activation needs /var/lib/nixos before systemd runs.
#
# Safety latch: nothing is wiped until /persist exists (`sudo mkdir /persist`).
{config, ...}: let
  inherit (config) username;
  home = "/home/${username}";
in {
  flake.modules.nixos.ephemeral = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.ephemeral;
    uid = toString config.users.users.${username}.uid;
    gid = toString config.ids.gids.users;

    # ROOT is only for testing the script on a fake tree, without mounts
    init = pkgs.writeScript "ephemeral-init" ''
      #!${pkgs.bash}/bin/bash
      set -u
      export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.util-linux]}
      R=''${ROOT:-}
      shopt -s dotglob nullglob

      # wipe DIR KEEP...: delete entries of DIR except KEEP and mount points
      wipe() {
        local dir=$1 e n
        shift
        for e in "$R$dir"/*; do
          n=''${e##*/}
          [[ " $* " == *" $n "* ]] && continue
          mountpoint -q "$e" && continue
          rm -rf --one-file-system -- "$e"
        done
      }

      # owned PATH: under the home directory every created level belongs to the user
      owned() {
        local p=$1
        while [[ $p == ${home}/* ]]; do
          chown ${uid}:${gid} "$R$p" "$R/persist$p"
          p=''${p%/*}
        done
        [[ $p == ${home} ]] && chown ${uid}:${gid} "$R$p" "$R/persist$p"
      }

      bind() {
        [ -z "$R" ] && mount --bind "/persist$1" "$1"
      }

      if [ -d "$R/persist" ]; then
        # First start after enabling: move what exists into /persist instead of wiping it
        for p in ${lib.escapeShellArgs (cfg.directories ++ cfg.files)}; do
          if [ ! -e "$R/persist$p" ] && [ -e "$R$p" ]; then
            mkdir -p "$R/persist''${p%/*}"
            mv -- "$R$p" "$R/persist$p"
          fi
        done

        echo "ephemeral: wiping /" >/dev/kmsg 2>/dev/null
        # /etc goes selectively: WSL writes resolv.conf and hosts before init
        wipe "" ${lib.concatStringsSep " " cfg.keep} etc
        wipe /etc resolv.conf hosts wsl.conf

        for d in ${lib.escapeShellArgs cfg.directories}; do
          mkdir -p "$R/persist$d" "$R$d"
          owned "$d"
          bind "$d"
        done
        for f in ${lib.escapeShellArgs cfg.files}; do
          mkdir -p "$R/persist''${f%/*}" "$R''${f%/*}"
          touch "$R/persist$f" "$R$f"
          owned "$f"
          bind "$f"
        done
      fi

      exec ''${SHIM:-${config.system.build.nativeUtils}/bin/systemd-shim} "$@"
    '';
  in {
    options.ephemeral = {
      enable = lib.mkEnableOption "wiping / on every WSL start";
      keep = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        # WSL's own files and mounts, the store, and what a failed activation
        # still needs to get you a shell
        default = ["nix" "persist" "init" "proc" "sys" "dev" "run" "mnt" "usr" "bin" "sbin" "lib" "lib64"];
        description = "Top-level entries of / that are never wiped.";
      };
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Directories bind mounted from /persist.";
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Files bind mounted from /persist.";
      };
    };

    config = lib.mkIf cfg.enable {
      ephemeral = {
        directories = [
          "/var/lib/nixos" # uid and gid map, activation needs it
          "/var/lib/systemd"
          "/var/log/journal"
          "${home}/nixos-wsl"
          "${home}/work"
          "${home}/.ssh"
          "${home}/.config/gh"
          "${home}/.local/share/fish"
          "${home}/.local/share/zoxide"
          "${home}/.local/share/direnv"
        ];
        files = [
          "/etc/machine-id"
          "${home}/.config/nushell/history.sqlite3"
        ];
      };

      system.build.ephemeralInit = init;
      system.activationScripts.shimSystemd = lib.mkForce (lib.stringAfter ["createSbin"] ''
        echo "setting up /sbin/init (ephemeral)..."
        ln -sf ${init} /sbin/init
      '');
    };
  };
}
