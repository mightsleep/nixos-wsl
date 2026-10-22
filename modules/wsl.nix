# NixOS-WSL integration
{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos.wsl = {pkgs, ...}: {
    imports = [inputs.nixos-wsl.nixosModules.default];

    wsl = {
      enable = true;
      defaultUser = config.username;
      # Uses the Windows OpenSSH agent, so keys can stay on the Windows side.
      # Without a running agent ssh just falls back to ~/.ssh.
      ssh-agent.enable = true;
      # Windows PATH stays (`code .`, `explorer.exe .`); costs a bit of speed
      # in command lookup over /mnt/c
      interop.includePath = true;
    };

    # VS Code Remote downloads its own node, which expects /lib64/ld-linux
    programs.nix-ld.enable = true;
    environment.systemPackages = [pkgs.wget];
  };
}
