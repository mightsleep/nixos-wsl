# Profiling and debugging. Hyper-V gives WSL no hardware counters: perf and
# samply sample on cpu-clock, cycles and cache misses are not available.
{
  flake.modules.nixos.debug = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.samply # `samply record ./prog`, opens the Firefox Profiler
      pkgs.perf
      pkgs.bpftrace # needs BTF from the WSL kernel: /sys/kernel/btf/vmlinux
      pkgs.strace
      pkgs.gdb
      pkgs.lnav
      pkgs.duf
    ];

    # perf and samply without sudo. Fine on a personal debug box, not on a shared one.
    boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  };
}
