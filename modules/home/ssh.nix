# SSH client. Corporate networks often allow only 80/443 out,
# GitHub serves SSH on 443 too, so we always go that way.
{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "github.com" = {
          HostName = "ssh.github.com";
          Port = 443;
          User = "git";
        };
        "*" = {
          AddKeysToAgent = "yes";
          ServerAliveInterval = 30;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%C";
          ControlPersist = "10m";
        };
      };
    };
  };
}
