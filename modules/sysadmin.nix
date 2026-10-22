# Small office, mostly Windows: RDP, SMB, Kerberos, SNMP, serial consoles, MSSQL
{config, ...}: {
  flake.modules.nixos.sysadmin = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.freerdp # xfreerdp, a window through WSLg
      pkgs.samba # smbclient, rpcclient, net
      pkgs.krb5 # kinit, klist, ktutil (keytab for decrypting your own AS-REP)
      pkgs.net-snmp # snmpwalk on switches and printers
      pkgs.tio # serial console, USB adapter attached through usbipd
      pkgs.sqlcmd
    ];

    # USB serial adapters show up as root:dialout
    users.users.${config.username}.extraGroups = ["dialout"];
  };
}
