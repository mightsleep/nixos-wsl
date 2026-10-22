# Network toolbox: one readable tool per job, a raw fallback only where the
# readable one has blind spots (doggo hides referrals and header flags).
{config, ...}: {
  flake.modules.nixos.net-tools = {pkgs, ...}: {
    environment.systemPackages = [
      # DNS
      pkgs.doggo
      pkgs.dnsutils # dig: the whole message, flags, authority, additional
      pkgs.whois

      # HTTP / TLS
      pkgs.xh
      # ldap:// and ldaps:// on top of the defaults (HTTP/3, SPNEGO, sftp are already in);
      # with --negotiate -u : it queries AD with your Kerberos ticket
      (pkgs.curl.override {ldapSupport = true;})
      pkgs.testssl # full TLS audit of a server
      pkgs.step-cli # `step certificate inspect https://host`
      pkgs.openssl # s_client for manual handshakes and STARTTLS

      # Path and latency: trip does ICMP, UDP and TCP (`-p tcp` when ICMP is blocked)
      pkgs.trippy
      pkgs.gping

      # L2
      pkgs.arp-scan

      # Packets: termshark daily, tshark and tcpdump for scripts
      pkgs.termshark
      pkgs.tcpdump

      pkgs.nmap
      pkgs.netcat-openbsd
      pkgs.iperf3
      pkgs.bandwhich # bandwidth per process
      pkgs.ipcalc
    ];

    # tshark, termshark and dumpcap; capturing for the wireshark group
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark-cli;
    };
    users.users.${config.username}.extraGroups = ["wireshark"];

    # LLDP/CDP neighbours via `lldpcli show neighbors`. Receive-only: a debug box
    # on someone else's network should not announce itself.
    services.lldpd = {
      enable = true;
      extraArgs = ["-r"];
    };

    # Raw sockets: capabilities instead of sudo
    security.wrappers = let
      raw = pkg: bin: caps: {
        owner = "root";
        group = "root";
        capabilities = caps;
        source = "${pkg}/bin/${bin}";
      };
    in {
      trip = raw pkgs.trippy "trip" "cap_net_raw+ep";
      tcpdump = raw pkgs.tcpdump "tcpdump" "cap_net_raw,cap_net_admin+ep";
      arp-scan = raw pkgs.arp-scan "arp-scan" "cap_net_raw+ep";
    };
  };
}
