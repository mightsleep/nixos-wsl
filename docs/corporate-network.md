# Corporate network notes

- SSH to GitHub goes to `ssh.github.com:443`, so it works where only 80/443 are open.
- `wsl.ssh-agent` bridges to the Windows OpenSSH agent. Keys can stay on Windows;
  without a running agent ssh falls back to `~/.ssh`.
- If DNS breaks behind a corporate VPN, put this into `%UserProfile%\.wslconfig`:

  ```ini
  [wsl2]
  dnsTunneling=true
  networkingMode=mirrored
  ```

- Mirrored networking is not real L2. Broadcast and multicast reach WSL, but the
  host's own traffic (Kerberos, SMB, LDAP) never does. Capture it on Windows and pipe
  it in:

  ```sh
  '/mnt/c/Program Files/Wireshark/dumpcap.exe' -i 4 -q -f "port 88" -w - | tshark -r - -n
  ```

- The Hyper-V firewall drops inbound connections to WSL even in mirrored mode
  (`iperf3 -s`, TFTP). Allow them from an admin PowerShell:

  ```powershell
  Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow
  ```

- USB serial adapters (for `tio`) and USB NICs get into WSL through
  [usbipd-win](https://github.com/dorssel/usbipd-win): `usbipd bind` and `usbipd attach --wsl`.
  Whether the WSL kernel has a driver for a given adapter is worth checking per device.
- No hardware counters under Hyper-V: perf and samply sample on `cpu-clock`.
- eza and neovim use Nerd Font icons. Install one on Windows (e.g. JetBrainsMono Nerd Font)
  and pick it in Windows Terminal.
- Neovim copies via OSC 52 and pastes via PowerShell, both UTF-8 safe.

